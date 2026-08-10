import Combine
import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class HomeRepositoryWriteTests: XCTestCase {
    func testTaskObservationEmitsAfterLocalInsertion() async throws {
        let tasks = SwiftDataTaskDataSource(modelContainer: try makeContainer())
        var iterator = tasks.observeTasks().values.makeAsyncIterator()
        let initial = try await iterator.next()
        let task = try AwanTask(
            id: UUID(),
            title: "Locally added",
            duration: TaskDuration(minutes: 30),
            isSplittable: false
        )

        try await tasks.addTask(task)
        let afterInsertion = try await iterator.next()

        XCTAssertEqual(initial, [])
        XCTAssertEqual(afterInsertion, [task])
    }

    func testSessionObservationEmitsCachedValueThenRemoteValue() async throws {
        let task = try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
        let cached = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: nil,
            timeRange: try TimeRange(start: date(hour: 9), end: date(hour: 10)),
            blocking: false,
            status: .planned
        )
        let remoteID = UUID()
        let container = try makeContainer()
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(task)
        try await sessions.addSession(cached)
        try await profiles.replaceProfile(profile())
        let remote = TestRemoteSessionDataSource(
            sessions: [
                SessionResponseDTO(
                    id: remoteID,
                    start: "2026-07-22T12:00:00",
                    end: "2026-07-22T13:00:00",
                    status: "SCHEDULED",
                    locked: false,
                    zoneId: nil,
                    taskID: task.id
                )
            ],
            deleteFails: false
        )
        let repository = DefaultSessionRepository(
            localDataSource: sessions,
            localProfileDataSource: profiles,
            remoteDataSource: remote
        )

        var iterator = repository.observeSessions(for: date(hour: 0)).values.makeAsyncIterator()
        let cachedEmission = try await iterator.next()
        let remoteEmission = try await iterator.next()
        let added = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: nil,
            timeRange: try TimeRange(start: date(hour: 14), end: date(hour: 15)),
            blocking: false,
            status: .planned
        )
        try await sessions.addSession(added)
        let localMutationEmission = try await iterator.next()

        XCTAssertEqual(cachedEmission, [cached])
        XCTAssertEqual(remoteEmission?.map(\.id), [remoteID])
        XCTAssertEqual(
            Set(localMutationEmission?.map(\.id) ?? []),
            [remoteID, added.id]
        )
        let requestedDates = await remote.requestedSessionDates()
        XCTAssertEqual(requestedDates, ["2026-07-22"])
    }

    func testTaskFetchForDateUsesCachedSessionsAndExcludesOtherDays() async throws {
        let selectedTask = try AwanTask(
            id: UUID(),
            title: "Selected day",
            duration: TaskDuration(minutes: 30),
            isSplittable: false
        )
        let otherTask = try AwanTask(
            id: UUID(),
            title: "Other day",
            duration: TaskDuration(minutes: 30),
            isSplittable: false
        )
        let container = try makeContainer()
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(selectedTask)
        try await tasks.addTask(otherTask)
        try await sessions.addSession(
            Session(
                id: UUID(),
                taskID: selectedTask.id,
                zoneID: nil,
                timeRange: try TimeRange(
                    start: date(day: 22, hour: 9),
                    end: date(day: 22, hour: 10)
                ),
                blocking: false,
                status: .planned
            )
        )
        try await sessions.addSession(
            Session(
                id: UUID(),
                taskID: otherTask.id,
                zoneID: nil,
                timeRange: try TimeRange(
                    start: date(day: 23, hour: 9),
                    end: date(day: 23, hour: 10)
                ),
                blocking: false,
                status: .planned
            )
        )
        try await profiles.replaceProfile(profile())
        let repository = DefaultTaskRepository(
            localDataSource: tasks,
            localSessionDataSource: sessions,
            localProfileDataSource: profiles,
            remoteTaskDataSource: UnavailableRemoteTaskDataSource(),
            remoteGoalDataSource: GoalRemoteDataSourceTestStub(mode: .failure),
            remoteSessionDataSource: TestRemoteSessionDataSource(
                sessions: [],
                deleteFails: false
            )
        )

        let selected = try await repository.fetchTasks(for: date(day: 22, hour: 0))

        XCTAssertEqual(selected, [selectedTask])
    }

    func testSessionDeleteFailureLeavesLocalCacheUnchanged() async throws {
        let task = try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
        let session = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: nil,
            timeRange: try TimeRange(start: date(hour: 10), end: date(hour: 11)),
            blocking: false,
            status: .planned
        )
        let container = try makeContainer()
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(task)
        try await sessions.addSession(session)
        try await profiles.replaceProfile(profile())
        let remote = TestRemoteSessionDataSource(sessions: [], deleteFails: true)
        let repository = DefaultSessionRepository(
            localDataSource: sessions,
            localProfileDataSource: profiles,
            remoteDataSource: remote
        )

        do {
            try await repository.deleteSession(id: session.id)
            XCTFail("Expected remote deletion to fail")
        } catch is RepositoryWriteTestError {
            // Expected.
        }

        let cachedSessions = try await sessions.fetchSessions()
        XCTAssertEqual(cachedSessions, [session])
        let deletedIDs = await remote.deletedSessionIDs()
        XCTAssertEqual(deletedIDs, [session.id])
    }

    func testTaskCreationSendsCategoryOnTaskAndZoneOnSession() async throws {
        let category = TaskCategory(id: UUID(), name: "Morning Focus")
        let zoneID = UUID()
        let taskID = UUID()
        let sessionID = UUID()
        let task = try AwanTask(
            id: UUID(),
            title: "Prepare presentation",
            description: "Create slides and rehearse",
            duration: TaskDuration(minutes: 120),
            isSplittable: false,
            category: category
        )
        let response = TaskWithSessionsResponseDTO(
            task: taskResponse(id: taskID, category: category),
            sessions: [
                SessionResponseDTO(
                    id: sessionID,
                    start: "2026-07-29T09:00:00",
                    end: "2026-07-29T11:00:00",
                    status: "SCHEDULED",
                    locked: false,
                    zoneId: zoneID,
                    taskID: taskID
                )
            ]
        )
        let container = try makeContainer()
        let remoteSessions = TestRemoteSessionDataSource(
            sessions: [],
            deleteFails: false,
            createResponse: response
        )
        let repository = DefaultTaskRepository(
            localDataSource: SwiftDataTaskDataSource(modelContainer: container),
            localSessionDataSource: SwiftDataSessionDataSource(modelContainer: container),
            localProfileDataSource: SwiftDataUserProfileDataSource(modelContainer: container),
            remoteTaskDataSource: UnavailableRemoteTaskDataSource(),
            remoteGoalDataSource: GoalRemoteDataSourceTestStub(mode: .failure),
            remoteSessionDataSource: remoteSessions
        )

        _ = try await repository.addTask(
            task,
            sessionZoneID: zoneID,
            startsAt: date(day: 29, hour: 9),
            durationMinutes: 120,
            timeZoneID: "UTC"
        )

        let requests = await remoteSessions.createdRequests()
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(request.task.categoryId, category.id)
        XCTAssertEqual(request.sessions?.first?.zoneId, zoneID)
    }

    func testStandaloneCreationOmitsCategoryAndZone() throws {
        let request = CreateTaskWithSessionsRequestDTO(
            task: .init(title: "Standalone", categoryId: nil),
            sessions: [
                .init(
                    zoneId: nil,
                    start: "2026-07-29T09:00:00",
                    end: "2026-07-29T10:00:00",
                    status: "SCHEDULED"
                )
            ]
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request))
                as? [String: Any]
        )
        let task = try XCTUnwrap(object["task"] as? [String: Any])
        let session = try XCTUnwrap((object["sessions"] as? [[String: Any]])?.first)

        XCTAssertNil(task["categoryId"])
        XCTAssertNil(session["zoneId"])
    }

    func testCategoryCreationEncodesCategoryAndResolvedZone() throws {
        let categoryID = UUID()
        let zoneID = UUID()
        let request = CreateTaskWithSessionsRequestDTO(
            task: .init(title: "Prepare presentation", categoryId: categoryID),
            sessions: [
                .init(
                    zoneId: zoneID,
                    start: "2026-07-29T09:00:00",
                    end: "2026-07-29T10:00:00",
                    status: "SCHEDULED"
                )
            ]
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request))
                as? [String: Any]
        )
        let task = try XCTUnwrap(object["task"] as? [String: Any])
        let session = try XCTUnwrap((object["sessions"] as? [[String: Any]])?.first)

        XCTAssertEqual(task["categoryId"] as? String, categoryID.uuidString)
        XCTAssertEqual(session["zoneId"] as? String, zoneID.uuidString)
    }

    func testTaskUpdateSendsCategoryAndReplacesCachedSessions() async throws {
        let category = TaskCategory(id: UUID(), name: "Evening Review")
        let zoneID = UUID()
        let taskID = UUID()
        let updatedTask = try AwanTask(
            id: taskID,
            title: "Updated",
            duration: TaskDuration(minutes: 60),
            isSplittable: false,
            category: category
        )
        let oldSession = Session(
            id: UUID(),
            taskID: taskID,
            zoneID: UUID(),
            timeRange: try TimeRange(
                start: date(day: 29, hour: 9),
                end: date(day: 29, hour: 10)
            ),
            blocking: false,
            status: .planned
        )
        let authoritativeSessionID = UUID()
        let remoteTasks = RecordingRemoteTaskDataSource(
            updateResponse: taskResponse(id: taskID, category: category)
        )
        let remoteSessions = TestRemoteSessionDataSource(
            sessions: [
                SessionResponseDTO(
                    id: authoritativeSessionID,
                    start: "2026-07-29T18:00:00",
                    end: "2026-07-29T19:00:00",
                    status: "SCHEDULED",
                    locked: false,
                    zoneId: zoneID,
                    taskID: taskID
                )
            ],
            deleteFails: false
        )
        let container = try makeContainer()
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(updatedTask)
        try await sessions.addSession(oldSession)
        try await profiles.replaceProfile(profile())
        let repository = DefaultTaskRepository(
            localDataSource: tasks,
            localSessionDataSource: sessions,
            localProfileDataSource: profiles,
            remoteTaskDataSource: remoteTasks,
            remoteGoalDataSource: GoalRemoteDataSourceTestStub(mode: .failure),
            remoteSessionDataSource: remoteSessions
        )

        try await repository.updateTask(updatedTask)

        let capturedUpdate = await remoteTasks.lastUpdate()
        let update = try XCTUnwrap(capturedUpdate)
        XCTAssertEqual(update.taskID, taskID)
        XCTAssertEqual(update.request.categoryID, category.id)
        let requestedTaskIDs = await remoteSessions.requestedTaskIDs()
        XCTAssertEqual(requestedTaskIDs, [taskID])
        let cached = try await sessions.fetchSessions()
        XCTAssertEqual(cached.map(\.id), [authoritativeSessionID])
        XCTAssertEqual(cached.first?.zoneID, zoneID)
    }

    private func taskResponse(
        id: UUID,
        category: TaskCategory?
    ) -> TaskInfoResponseDTO {
        TaskInfoResponseDTO(
            id: id,
            title: "Prepare presentation",
            description: nil,
            status: "SCHEDULED",
            goalID: nil,
            estimatedDuration: 60,
            mandatory: true,
            estimatedPoints: 50,
            isSplittable: false,
            dependencyIDs: [],
            category: category.map {
                CategoryResponseDTO(id: $0.id, name: $0.name)
            }
        )
    }

    private func profile() throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "home@awan.app",
            firstName: "Home",
            lastName: "User",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 8, minute: 0),
                sleepTime: try LocalTime(hour: 0, minute: 0)
            )
        )
    }

    private func date(day: Int = 22, hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar.date(
            from: DateComponents(year: 2026, month: 7, day: day, hour: hour)
        ) ?? .distantPast
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

private enum RepositoryWriteTestError: Error {
    case remoteFailure
}

private actor TestRemoteSessionDataSource: RemoteSessionDataSourceProtocol {
    private var deletedIDs: [UUID] = []
    private var requestedDates: [String] = []
    private var taskSessionIDs: [UUID] = []
    private var createRequestsValue: [CreateTaskWithSessionsRequestDTO] = []
    private let sessions: [SessionResponseDTO]
    private let deleteFails: Bool
    private let createResponse: TaskWithSessionsResponseDTO?

    init(
        sessions: [SessionResponseDTO],
        deleteFails: Bool,
        createResponse: TaskWithSessionsResponseDTO? = nil
    ) {
        self.sessions = sessions
        self.deleteFails = deleteFails
        self.createResponse = createResponse
    }

    func deletedSessionIDs() -> [UUID] { deletedIDs }

    func requestedSessionDates() -> [String] { requestedDates }
    func requestedTaskIDs() -> [UUID] { taskSessionIDs }
    func createdRequests() -> [CreateTaskWithSessionsRequestDTO] { createRequestsValue }

    func getSessions(date: String) -> [SessionResponseDTO] {
        requestedDates.append(date)
        return sessions
    }
    func getSessions(
        startDate: String,
        endDate: String
    ) -> [String: [SessionResponseDTO]] {
        [startDate: sessions]
    }

    func deleteSession(sessionID: UUID) throws {
        deletedIDs.append(sessionID)
        if deleteFails { throw RepositoryWriteTestError.remoteFailure }
    }

    func getSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func updateSession(
        sessionID: UUID,
        request: UpdateSessionRequestDTO
    ) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func updateSessionStatus(sessionID: UUID, status: String) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func lockSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func unlockSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func createTaskWithSessions(
        request: CreateTaskWithSessionsRequestDTO
    ) throws -> TaskWithSessionsResponseDTO {
        createRequestsValue.append(request)
        guard let createResponse else {
            throw RepositoryWriteTestError.remoteFailure
        }
        return createResponse
    }
    func getTaskSessions(taskID: UUID) -> [SessionResponseDTO] {
        taskSessionIDs.append(taskID)
        return sessions
    }
}

private actor RecordingRemoteTaskDataSource: RemoteTaskDataSource {
    struct Update: Sendable {
        let taskID: UUID
        let request: UpdateTaskRequestDTO
    }

    private let updateResponse: TaskInfoResponseDTO
    private var update: Update?

    init(updateResponse: TaskInfoResponseDTO) {
        self.updateResponse = updateResponse
    }

    func lastUpdate() -> Update? { update }
    func getTasks(date: String) async throws -> [TaskWithSessionsResponseDTO] { [] }
    func getTasks(
        startDate: String,
        endDate: String
    ) async throws -> [String: [TaskWithSessionsResponseDTO]] { [:] }
    func createTask(_ request: CreateTaskRequestDTO) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func getTask(taskID: UUID) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func updateTask(
        taskID: UUID,
        request: UpdateTaskRequestDTO
    ) async throws -> TaskInfoResponseDTO {
        update = Update(taskID: taskID, request: request)
        return updateResponse
    }
    func moveTask(
        taskID: UUID,
        request: MoveTaskRequestDTO
    ) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func completeTask(taskID: UUID) async throws -> TaskCompleteResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func uncompleteTask(taskID: UUID) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func deleteTask(taskID: UUID, cascade: Bool) async throws {}
    func addDependency(taskID: UUID, request: AddDependencyRequestDTO) async throws {}
    func removeDependency(taskID: UUID, dependsOnTaskID: UUID) async throws {}
    func listDependencies(taskID: UUID) async throws -> [TaskInfoResponseDTO] { [] }
    func listDependents(taskID: UUID) async throws -> [TaskInfoResponseDTO] { [] }
}

private struct UnavailableRemoteTaskDataSource: RemoteTaskDataSource {
    func getTasks(date: String) async throws -> [TaskWithSessionsResponseDTO] {
        throw RepositoryWriteTestError.remoteFailure
    }

    func getTasks(
        startDate: String,
        endDate: String
    ) async throws -> [String: [TaskWithSessionsResponseDTO]] {
        throw RepositoryWriteTestError.remoteFailure
    }

    func createTask(_ request: CreateTaskRequestDTO) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func getTask(taskID: UUID) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func updateTask(
        taskID: UUID,
        request: UpdateTaskRequestDTO
    ) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func moveTask(
        taskID: UUID,
        request: MoveTaskRequestDTO
    ) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func completeTask(taskID: UUID) async throws -> TaskCompleteResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func uncompleteTask(taskID: UUID) async throws -> TaskInfoResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }

    func deleteTask(taskID: UUID, cascade: Bool) async throws {
        throw RepositoryWriteTestError.remoteFailure
    }

    func addDependency(taskID: UUID, request: AddDependencyRequestDTO) async throws {
        throw RepositoryWriteTestError.remoteFailure
    }

    func removeDependency(taskID: UUID, dependsOnTaskID: UUID) async throws {
        throw RepositoryWriteTestError.remoteFailure
    }

    func listDependencies(taskID: UUID) async throws -> [TaskInfoResponseDTO] {
        throw RepositoryWriteTestError.remoteFailure
    }

    func listDependents(taskID: UUID) async throws -> [TaskInfoResponseDTO] {
        throw RepositoryWriteTestError.remoteFailure
    }
}
