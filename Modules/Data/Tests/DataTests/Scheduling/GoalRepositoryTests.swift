import XCTest
@testable import Data
import Domain
import Foundation

final class GoalRepositoryTests: XCTestCase {
    private var sut: DefaultGoalRepository!
    private var localGoalDataSource: MockLocalGoalDataSource!
    private var remoteGoalDataSource: MockRemoteGoalDataSource!
    private var remoteTaskDataSource: MockRemoteTaskDataSource!
    private var localTaskDataSource: MockLocalTaskDataSource!

    override func setUp() {
        super.setUp()
        localGoalDataSource = MockLocalGoalDataSource()
        remoteGoalDataSource = MockRemoteGoalDataSource()
        remoteTaskDataSource = MockRemoteTaskDataSource()
        localTaskDataSource = MockLocalTaskDataSource()

        sut = DefaultGoalRepository(
            localDataSource: localGoalDataSource,
            remoteDataSource: remoteGoalDataSource,
            remoteTaskDataSource: remoteTaskDataSource,
            localTaskDataSource: localTaskDataSource
        )
    }

    override func tearDown() {
        sut = nil
        localGoalDataSource = nil
        remoteGoalDataSource = nil
        remoteTaskDataSource = nil
        localTaskDataSource = nil
        super.tearDown()
    }

    func testAddTaskToGoal_UsesMoveTaskEndpoint() async throws {
        // Given
        let goalID = UUID()
        let task = AwanTask(
            id: UUID(),
            title: "Test Task",
            description: nil,
            duration: TaskDuration(minutes: 30),
            isSplittable: false
        )
        remoteTaskDataSource.moveTaskResult = TaskInfoResponseDTO(
            id: task.id.uuidString,
            title: task.title,
            description: nil,
            status: "ACTIVE",
            estimatedDuration: 30,
            estimatedPoints: 0,
            allowTaskSplitting: false,
            mandatory: true,
            createdAt: "",
            updatedAt: "",
            deletedAt: nil,
            goalId: goalID,
            dependsOnTempIds: [],
            isArchived: false,
            goal: nil
        )

        // When
        try await sut.addTaskToGoal(goalID: goalID, task: task)

        // Then
        XCTAssertEqual(remoteTaskDataSource.moveTaskCalls.count, 1)
        XCTAssertEqual(remoteTaskDataSource.moveTaskCalls.first?.taskID, task.id)
        XCTAssertEqual(remoteTaskDataSource.moveTaskCalls.first?.request.goalID, goalID)

        XCTAssertEqual(localTaskDataSource.updateTaskCalls.count, 1)
        XCTAssertEqual(localTaskDataSource.updateTaskCalls.first?.goalID, goalID)
    }
}

// Mocks

private class MockLocalGoalDataSource: LocalGoalDataSource, @unchecked Sendable {
    func fetchGoals() async throws -> [Domain.Goal] { [] }
    func observeGoals() -> AnyPublisher<[Domain.Goal], Error> { Empty().eraseToAnyPublisher() }
    func addGoal(_ goal: Domain.Goal) async throws {}
    func updateGoal(_ goal: Domain.Goal) async throws {}
    func replaceActiveGoals(_ goals: [Domain.Goal]) async throws {}
    func deleteGoal(id: UUID) async throws {}
    func deleteAllGoals() async throws {}
}

private class MockRemoteGoalDataSource: RemoteGoalDataSource, @unchecked Sendable {
    func listGoals(parameters: Data.ListGoalsParameters) async throws -> Data.PageResponseDTO<Data.GoalResponseDTO> {
        fatalError()
    }
    func getGoalTasks(goalId: UUID) async throws -> [Data.TaskInfoResponseDTO] { [] }
    func bulkAddTasks(goalId: UUID, request: Data.BulkAddTasksRequestDTO) async throws -> [Data.TaskInfoResponseDTO] { [] }
    func updateGoal(_ goal: Data.GoalResponseDTO) async throws -> Data.GoalResponseDTO { fatalError() }
    func createGoal(_ request: Data.CreateGoalRequestDTO) async throws -> Data.GoalResponseDTO { fatalError() }
    func deleteGoal(goalId: UUID) async throws {}
    func getInbox() async throws -> Data.InboxResponseDTO { fatalError() }
}

private class MockRemoteTaskDataSource: RemoteTaskDataSource, @unchecked Sendable {
    var moveTaskCalls: [(taskID: UUID, request: MoveTaskRequestDTO)] = []
    var moveTaskResult: TaskInfoResponseDTO?

    func listTasks(parameters: Data.ListTasksParameters) async throws -> Data.PageResponseDTO<Data.TaskInfoResponseDTO> { fatalError() }
    func createTask(_ request: Data.CreateTaskRequestDTO) async throws -> Data.TaskInfoResponseDTO { fatalError() }
    func getTask(id: UUID) async throws -> Data.TaskInfoResponseDTO { fatalError() }
    func updateTask(id: UUID, request: Data.UpdateTaskRequestDTO) async throws -> Data.TaskInfoResponseDTO { fatalError() }
    func moveTask(taskID: UUID, request: Data.MoveTaskRequestDTO) async throws -> Data.TaskInfoResponseDTO {
        moveTaskCalls.append((taskID, request))
        if let moveTaskResult { return moveTaskResult }
        fatalError()
    }
    func deleteTasks(ids: [UUID]) async throws {}
    func markTasks(ids: [UUID], markCompleted: Bool) async throws -> Data.CompletionResultResponseDTO { fatalError() }
    func createBulkTasks(_ request: Data.BulkAddTasksRequestDTO) async throws -> [Data.TaskInfoResponseDTO] { fatalError() }
}

private class MockLocalTaskDataSource: LocalTaskDataSource, @unchecked Sendable {
    var updateTaskCalls: [AwanTask] = []
    func fetchTasks() async throws -> [Domain.AwanTask] { [] }
    func observeTasks() -> AnyPublisher<[Domain.AwanTask], Error> { Empty().eraseToAnyPublisher() }
    func updateTask(_ task: Domain.AwanTask) async throws { updateTaskCalls.append(task) }
    func upsertTasks(_ tasks: [Domain.AwanTask]) async throws {}
    func removeTasks(ids: [UUID]) async throws {}
    func deleteAllTasks() async throws {}
}
