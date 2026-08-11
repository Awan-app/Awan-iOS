import Combine
import Domain
import Foundation
import XCTest
@testable import Presentation

// MARK: - InboxViewModelTests

@MainActor
final class InboxViewModelTests: XCTestCase {

    // MARK: - Load

    func testAppeared_setsLoadingThenPublishesTasks() async throws {
        let task = try makeInboxTask(derivedStatus: .active)
        let stub = InboxUseCaseStub(tasks: [task])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && !viewModel.state.allTasks.isEmpty }

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(viewModel.state.allTasks.count, 1)
        XCTAssertEqual(viewModel.state.allTasks.first?.id, task.id)
    }

    func testRefresh_reloadsTaskList() async throws {
        let task = try makeInboxTask(derivedStatus: .drafted)
        let stub = InboxUseCaseStub(tasks: [task])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.refresh)
        await waitUntil { !viewModel.state.isLoading }

        XCTAssertEqual(viewModel.state.allTasks.count, 1)
    }

    // MARK: - Search

    func testSearchQuery_filtersTasksByTitle() async throws {
        let matchTask = try makeInboxTask(title: "Presentation slides", derivedStatus: .active)
        let nonMatchTask = try makeInboxTask(title: "Database setup", derivedStatus: .drafted)
        let stub = InboxUseCaseStub(tasks: [matchTask, nonMatchTask])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.searchQueryChanged("presentation"))

        XCTAssertEqual(viewModel.state.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.state.filteredTasks.first?.id, matchTask.id)
    }

    func testEmptySearchQuery_returnsAllTasks() async throws {
        let task1 = try makeInboxTask(derivedStatus: .active)
        let task2 = try makeInboxTask(derivedStatus: .drafted)
        let stub = InboxUseCaseStub(tasks: [task1, task2])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.searchQueryChanged(""))
        XCTAssertEqual(viewModel.state.filteredTasks.count, 2)
    }

    // MARK: - Task Filters

    func testFilterActive_showsOnlyActiveTasks() async throws {
        let active = try makeInboxTask(derivedStatus: .active)
        let drafted = try makeInboxTask(derivedStatus: .drafted)
        let completed = try makeInboxTask(derivedStatus: .completed)
        let stub = InboxUseCaseStub(tasks: [active, drafted, completed])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.taskFilterChanged(.active))

        XCTAssertEqual(viewModel.state.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.state.filteredTasks.first?.id, active.id)
    }

    func testFilterDrafted_showsOnlyDraftedTasks() async throws {
        let drafted = try makeInboxTask(derivedStatus: .drafted)
        let active = try makeInboxTask(derivedStatus: .active)
        let stub = InboxUseCaseStub(tasks: [drafted, active])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.taskFilterChanged(.drafted))

        XCTAssertEqual(viewModel.state.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.state.filteredTasks.first?.id, drafted.id)
    }

    func testFilterAll_showsAllTasks() async throws {
        let task1 = try makeInboxTask(derivedStatus: .active)
        let task2 = try makeInboxTask(derivedStatus: .drafted)
        let task3 = try makeInboxTask(derivedStatus: .completed)
        let stub = InboxUseCaseStub(tasks: [task1, task2, task3])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.taskFilterChanged(.all))
        XCTAssertEqual(viewModel.state.filteredTasks.count, 3)
    }

    // MARK: - Task Expansion

    func testToggleExpansion_expandsTask() async throws {
        let task = try makeInboxTask(derivedStatus: .active)
        let stub = InboxUseCaseStub(tasks: [task])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        XCTAssertFalse(viewModel.state.expandedTaskIDs.contains(task.id))

        viewModel.send(.toggleTaskExpansion(task.id))
        XCTAssertTrue(viewModel.state.expandedTaskIDs.contains(task.id))
    }

    func testToggleExpansion_collapsesExpandedTask() async throws {
        let task = try makeInboxTask(derivedStatus: .active)
        let stub = InboxUseCaseStub(tasks: [task])
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.toggleTaskExpansion(task.id))
        XCTAssertTrue(viewModel.state.expandedTaskIDs.contains(task.id))

        viewModel.send(.toggleTaskExpansion(task.id))
        XCTAssertFalse(viewModel.state.expandedTaskIDs.contains(task.id))
    }

    // MARK: - Error Dismissal

    func testDismissError_clearsFailureMessage() async throws {
        let stub = InboxUseCaseStub(error: URLError(.badServerResponse))
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { viewModel.state.failureMessage != nil }

        XCTAssertNotNil(viewModel.state.failureMessage)
        viewModel.send(.dismissError)
        XCTAssertNil(viewModel.state.failureMessage)
    }

    // MARK: - Tab Selection

    func testSelectTopTab_updatesSelectedTab() {
        let stub = InboxUseCaseStub(tasks: [])
        let viewModel = makeViewModel(stub: stub)

        XCTAssertEqual(viewModel.state.selectedTopTab, .inbox)
        viewModel.send(.selectTopTab(.goals))
        XCTAssertEqual(viewModel.state.selectedTopTab, .goals)
    }

    // MARK: - Task Actions

    func testCompleteTask_callsSetTaskCompletionUseCase() async throws {
        let task = try makeInboxTask(derivedStatus: .active)
        let stub = InboxUseCaseStub(tasks: [task])
        let mockComplete = MockSetTaskCompletionUseCase()
        let viewModel = InboxViewModel(
            useCases: InboxUseCases(
                fetchInboxTasks: stub,
                setTaskCompletion: mockComplete
            ),
            mapper: InboxStateMapper()
        )

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.completeTask(task.id))
        await waitUntil { mockComplete.completedTaskID == task.id }

        XCTAssertEqual(mockComplete.completedTaskID, task.id)
    }

    func testDeleteTask_callsDeleteInboxTask() async throws {
        let task = try makeInboxTask(derivedStatus: .drafted)
        let stub = InboxUseCaseStub(tasks: [task])
        let mockDelete = MockDeleteInboxTaskUseCase()
        let viewModel = InboxViewModel(
            useCases: InboxUseCases(
                fetchInboxTasks: stub,
                deleteInboxTask: mockDelete
            ),
            mapper: InboxStateMapper()
        )

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading }

        viewModel.send(.deleteTask(task.id))
        await waitUntil { mockDelete.deletedTaskID == task.id }

        XCTAssertEqual(mockDelete.deletedTaskID, task.id)
    }

    // MARK: - Helpers

    private func makeViewModel(stub: InboxUseCaseStub) -> InboxViewModel {
        InboxViewModel(
            useCases: InboxUseCases(fetchInboxTasks: stub),
            mapper: InboxStateMapper()
        )
    }

    private func makeInboxTask(
        title: String = "Task",
        derivedStatus: InboxTaskStatus
    ) throws -> InboxTaskItem {
        let id = UUID()
        return InboxTaskItem(
            id: id,
            title: title,
            description: nil,
            derivedStatus: derivedStatus,
            sessionsSummary: "No sessions",
            sessionItems: [],
            rawTask: AwanTask(
                id: id,
                title: title,
                duration: try TaskDuration(minutes: 30),
                isSplittable: false
            )
        )
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<500 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Timed out waiting for expected Inbox state.", file: file, line: line)
    }
}

// MARK: - Stubs & Mocks

private struct InboxUseCaseStub: FetchInboxTasksUseCase {
    private let items: [InboxTaskItem]
    private let error: Error?

    init(tasks: [InboxTaskItem] = [], error: Error? = nil) {
        self.items = tasks
        self.error = error
    }

    func execute() async throws -> [Domain.InboxTask] {
        if let error { throw error }
        return items.map { item in
            Domain.InboxTask(
                task: item.rawTask,
                sessions: [],
                derivedStatus: item.derivedStatus
            )
        }
    }
}

private final class MockSetTaskCompletionUseCase: SetTaskCompletionUseCase, @unchecked Sendable {
    var completedTaskID: UUID?
    var lastIsCompleted: Bool?

    func execute(
        taskID: UUID,
        isCompleted: Bool
    ) async throws -> SetTaskCompletionResult {
        self.completedTaskID = taskID
        self.lastIsCompleted = isCompleted
        let task = AwanTask(
            id: taskID,
            status: isCompleted ? .completed : .drafted,
            duration: try TaskDuration(minutes: 30),
            isSplittable: false
        )
        if !isCompleted {
            return .uncompleted(task)
        }
        return .completed(
            TaskCompletionResult(
                task: task,
                completedSessions: [],
                reward: CompletionReward(
                    points: .init(
                        awarded: false,
                        amount: 0,
                        oldValue: 0,
                        newValue: 0
                    ),
                    streak: .init(
                        updated: false,
                        oldValue: 0,
                        newValue: 0,
                        maxStreakBroken: false,
                        maxStreakOld: 0,
                        maxStreakNew: 0
                    )
                )
            )
        )
    }
}

private final class MockDeleteInboxTaskUseCase: DeleteInboxTaskUseCase, @unchecked Sendable {
    var deletedTaskID: UUID?

    func execute(taskID: UUID) async throws {
        self.deletedTaskID = taskID
    }
}
