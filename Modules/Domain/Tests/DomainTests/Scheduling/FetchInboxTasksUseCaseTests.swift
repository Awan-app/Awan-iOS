import Combine
import Foundation
import XCTest
@testable import Domain

// MARK: - FetchInboxTasksUseCaseTests

final class FetchInboxTasksUseCaseTests: XCTestCase {
    private let inboxGoalID = UUID()

    // MARK: - Backend-authoritative Inbox membership

    func testReturnsRepositoryInboxTasksWithNonNilGoalID() async throws {
        let inboxTask = try makeTask(goalID: inboxGoalID)
        let regularGoalTask = try makeTask(goalID: UUID())

        let taskRepo = InboxTaskRepositoryStub(
            allTasks: [inboxTask, regularGoalTask],
            inboxTasks: [inboxTask]
        )
        let sessionRepo = InboxSessionRepositoryStub(sessions: [])
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, inboxTask.id)
        XCTAssertEqual(result.first?.task.goalID, inboxGoalID)
    }

    func testReturnsEmptyWhenRepositoryInboxIsEmpty() async throws {
        let regularGoalTask = try makeTask(goalID: UUID())

        let taskRepo = InboxTaskRepositoryStub(
            allTasks: [regularGoalTask],
            inboxTasks: []
        )
        let sessionRepo = InboxSessionRepositoryStub(sessions: [])
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Session grouping

    func testGroupsSessionsByTaskID() async throws {
        let task1 = try makeTask(goalID: inboxGoalID)
        let task2 = try makeTask(goalID: inboxGoalID)
        let session1a = makeSession(taskID: task1.id)
        let session1b = makeSession(taskID: task1.id)
        let session2a = makeSession(taskID: task2.id)

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [task1, task2])
        let sessionRepo = InboxSessionRepositoryStub(sessions: [session1a, session1b, session2a])
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()

        let result1 = try XCTUnwrap(result.first { $0.id == task1.id })
        let result2 = try XCTUnwrap(result.first { $0.id == task2.id })

        XCTAssertEqual(result1.sessions.count, 2)
        XCTAssertEqual(result2.sessions.count, 1)
    }

    func testTaskWithNoSessions_hasDraftedStatus() async throws {
        let task = try makeTask(goalID: inboxGoalID)

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [task])
        let sessionRepo = InboxSessionRepositoryStub(sessions: [])
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()

        XCTAssertEqual(result.first?.derivedStatus, .drafted)
    }

    func testTaskWithAllCancelledSessions_hasCancelledStatus() async throws {
        let task = try makeTask(goalID: inboxGoalID)
        let sessions = [
            makeSession(taskID: task.id, status: .cancelled),
            makeSession(taskID: task.id, status: .cancelled)
        ]

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [task])
        let sessionRepo = InboxSessionRepositoryStub(sessions: sessions)
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()
        XCTAssertEqual(result.first?.derivedStatus, .cancelled)
    }

    func testTaskWithAllCompletedSessions_remainsActiveWithoutTaskCompletion() async throws {
        let task = try makeTask(goalID: inboxGoalID)
        let sessions = [
            makeSession(taskID: task.id, status: .completed),
            makeSession(taskID: task.id, status: .completed)
        ]

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [task])
        let sessionRepo = InboxSessionRepositoryStub(sessions: sessions)
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()
        XCTAssertEqual(result.first?.derivedStatus, .active)
    }

    func testTaskWithMixedSessions_hasActiveStatus() async throws {
        let task = try makeTask(goalID: inboxGoalID)
        let sessions = [
            makeSession(taskID: task.id, status: .planned),
            makeSession(taskID: task.id, status: .completed)
        ]

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [task])
        let sessionRepo = InboxSessionRepositoryStub(sessions: sessions)
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()
        XCTAssertEqual(result.first?.derivedStatus, .active)
    }

    func testSessionsForOtherTasksAreNotGroupedToInboxTask() async throws {
        let inboxTask = try makeTask(goalID: inboxGoalID)
        let otherTaskID = UUID()
        let sessionForOther = makeSession(taskID: otherTaskID, status: .planned)

        let taskRepo = InboxTaskRepositoryStub(inboxTasks: [inboxTask])
        let sessionRepo = InboxSessionRepositoryStub(sessions: [sessionForOther])
        let useCase = DefaultFetchInboxTasksUseCase(taskRepository: taskRepo, sessionRepository: sessionRepo)

        let result = try await useCase.execute()
        XCTAssertEqual(result.first?.sessions.isEmpty, true)
        XCTAssertEqual(result.first?.derivedStatus, .drafted)
    }

    // MARK: - Helpers

    private func makeTask(goalID: UUID?) throws -> AwanTask {
        AwanTask(
            id: UUID(),
            title: "Task \(UUID().uuidString.prefix(4))",
            goalID: goalID,
            duration: try TaskDuration(minutes: 60),
            isSplittable: false
        )
    }

    private func makeSession(taskID: UUID, status: Session.Status = .planned) -> Session {
        Session(
            id: UUID(),
            taskID: taskID,
            zoneID: nil,
            timeRange: (try? TimeRange(start: Date(), end: Date().addingTimeInterval(3600))) ?? .distantFutureRange,
            blocking: false,
            status: status
        )
    }
}

// MARK: - Stubs

private actor InboxTaskRepositoryStub: TaskRepository {
    private let allTasks: [AwanTask]
    private let inboxTasks: [AwanTask]

    init(allTasks: [AwanTask]? = nil, inboxTasks: [AwanTask]) {
        self.allTasks = allTasks ?? inboxTasks
        self.inboxTasks = inboxTasks
    }

    func fetchTasks() -> [AwanTask] { allTasks }
    func fetchInboxTasks() -> [AwanTask] { inboxTasks }

    nonisolated func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    nonisolated func observeInboxTasks() -> AnyPublisher<[AwanTask], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func addTask(
        _ task: AwanTask,
        sessionZoneID: UUID?,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) -> (task: AwanTask, sessions: [Session]) { (task, []) }

    func updateTask(_ task: AwanTask) {}
    func completeTask(id: UUID) throws -> TaskCompletionResult {
        throw SchedulingError.entityNotFound(id: id)
    }
    func uncompleteTask(id: UUID) throws -> AwanTask {
        throw SchedulingError.entityNotFound(id: id)
    }
    func refreshTask(id: UUID) throws -> AwanTask {
        guard let task = allTasks.first(where: { $0.id == id }) else {
            throw SchedulingError.entityNotFound(id: id)
        }
        return task
    }
    func deleteTask(id: UUID) {}
    func deleteAllTasks() {}
    func addDependency(taskID: UUID, dependsOnID: UUID) {}
    func removeDependency(taskID: UUID, dependsOnID: UUID) {}
    func fetchDependencies(taskID: UUID) -> [AwanTask] { [] }
    func fetchDependents(taskID: UUID) -> [AwanTask] { [] }
}

private actor InboxSessionRepositoryStub: SessionRepository {
    private let sessions: [Session]
    init(sessions: [Session]) { self.sessions = sessions }

    func fetchSessions() -> [Session] { sessions }

    nonisolated func observeSessions() -> AnyPublisher<[Session], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    nonisolated func observeSessions(for date: Date) -> AnyPublisher<[Session], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func addSession(_ session: Session) {}
    func updateSession(_ session: Session) {}
    func deleteSession(id: UUID) {}
    func deleteSessions(taskID: UUID) {}
    func deleteAllSessions() {}
}

private extension TimeRange {
    static var distantFutureRange: TimeRange {
        try! TimeRange(start: .distantFuture, end: .distantFuture.addingTimeInterval(3600))
    }
}
