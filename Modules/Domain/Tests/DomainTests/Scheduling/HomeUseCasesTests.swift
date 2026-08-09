import Combine
import Foundation
import XCTest
@testable import Domain

final class HomeUseCasesTests: XCTestCase {
    func testReadUseCasesReturnRepositoryValues() async throws {
        let task = try makeTask()
        let session = try makeSession(taskID: task.id)
        let profile = try makeProfile()
        let taskRepository = TaskRepositoryStub(tasks: [task])
        let sessionRepository = SessionRepositoryStub(sessions: [session])
        let profileRepository = UserProfileRepositoryStub(profile: profile)

        let selectedDay = date(hour: 0)
        let tasks = try await DefaultFetchTasksUseCase(repository: taskRepository)
            .execute(for: selectedDay)
        let sessions = try await DefaultFetchSessionsUseCase(repository: sessionRepository)
            .execute(for: selectedDay)
        let user = try await DefaultGetUserProfileUseCase(repository: profileRepository).execute()

        XCTAssertEqual(tasks, [task])
        XCTAssertEqual(sessions, [session])
        XCTAssertEqual(user, profile)
    }

    func testReschedulePreservesDurationAndLocksSession() async throws {
        let task = try makeTask()
        let session = try makeSession(taskID: task.id, blocking: false)
        let repository = SessionRepositoryStub(sessions: [session])
        let newStart = date(hour: 13)

        let updated = try await DefaultRescheduleSessionUseCase(repository: repository)
            .execute(sessionID: session.id, newStart: newStart)

        XCTAssertEqual(updated.timeRange.durationMinutes, session.timeRange.durationMinutes)
        XCTAssertEqual(updated.timeRange.start, newStart)
        XCTAssertTrue(updated.blocking)
        let stored = await repository.values()
        XCTAssertEqual(stored, [updated])
    }

    func testSetLockUpdatesOnlyLockState() async throws {
        let task = try makeTask()
        let session = try makeSession(taskID: task.id, blocking: false)
        let repository = SessionRepositoryStub(sessions: [session])

        let updated = try await DefaultSetSessionLockUseCase(repository: repository)
            .execute(sessionID: session.id, isLocked: true)

        XCTAssertTrue(updated.blocking)
        XCTAssertEqual(updated.timeRange, session.timeRange)
        XCTAssertEqual(updated.status, session.status)
    }

    func testSetCompletionUpdatesOnlySessionStatus() async throws {
        let task = try makeTask()
        let session = try makeSession(taskID: task.id, blocking: true)
        let sessionRepo = SessionRepositoryStub(sessions: [session])
        let profileRepo = UserProfileRepositoryStub(profile: try makeProfile())

        let useCase = DefaultSetSessionCompletionUseCase(
            sessionRepository: sessionRepo,
            userProfileRepository: profileRepo
        )

        let completedResult = try await useCase.execute(sessionID: session.id, isCompleted: true)
        if case let .completed(res) = completedResult {
            XCTAssertEqual(res.session.status, .completed)
            XCTAssertEqual(res.session.timeRange, session.timeRange)
            XCTAssertEqual(res.session.blocking, session.blocking)
        } else {
            XCTFail("Expected .completed")
        }

        let uncompletedResult = try await useCase.execute(sessionID: session.id, isCompleted: false)
        if case let .uncompleted(uncompletedSession) = uncompletedResult {
            XCTAssertEqual(uncompletedSession.status, .planned)
        } else {
            XCTFail("Expected .uncompleted")
        }
    }

    func testDeleteRemovesOnlyRequestedSession() async throws {
        let task = try makeTask()
        let first = try makeSession(taskID: task.id)
        let second = try makeSession(taskID: task.id, startHour: 14)
        let repository = SessionRepositoryStub(sessions: [first, second])

        try await DefaultDeleteSessionUseCase(repository: repository)
            .execute(sessionID: first.id)

        let remaining = await repository.values()
        XCTAssertEqual(remaining, [second])
    }

    func testCreateTaskUsesFirstZoneMatchingSelectedCategory() async throws {
        let category = TaskCategory(id: UUID(), name: "Focus")
        let morningZone = try Zone(
            id: UUID(),
            name: "Morning Focus",
            color: ZoneColor(hex: "#4CAF50"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 11, minute: 0),
            category: category
        )
        let afternoonZone = try Zone(
            id: UUID(),
            name: "Afternoon Focus",
            color: ZoneColor(hex: "#2196F3"),
            startTime: LocalTime(hour: 13, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0),
            category: category
        )
        let repository = TaskRepositoryStub(tasks: [])
        let workspace = ScheduleWorkspace(
            zones: [morningZone, afternoonZone],
            goals: [],
            tasks: [],
            sessions: []
        )
        let start = date(hour: 14)
        _ = try await DefaultCreateTaskUseCase(
            taskRepository: repository,
            workspaceProvider: ScheduleWorkspaceProviderStub(workspace: workspace)
        ).execute(
            CreateTaskRequest(
                title: "Prepare presentation",
                durationMinutes: 120,
                categoryID: category.id,
                isSplittable: false,
                startsAt: start,
                selectedDay: date(hour: 0),
                timeZone: .gmt
            )
        )

        let capturedAddition = await repository.lastAddition()
        let addition = try XCTUnwrap(capturedAddition)
        XCTAssertEqual(addition.task.category, category)
        XCTAssertEqual(addition.sessionZoneID, morningZone.id)
        XCTAssertEqual(addition.startsAt, start)
    }

    func testCreateTaskWithExplicitZonePassesExactSessionZone() async throws {
        let category = TaskCategory(id: UUID(), name: "Work")
        let morningZone = try Zone(
            id: UUID(),
            name: "Morning Work",
            color: ZoneColor(hex: "#4CAF50"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 11, minute: 0),
            category: category
        )
        let repository = TaskRepositoryStub(tasks: [])
        let workspace = ScheduleWorkspace(
            zones: [morningZone],
            goals: [],
            tasks: [],
            sessions: []
        )

        _ = try await DefaultCreateTaskUseCase(
            taskRepository: repository,
            workspaceProvider: ScheduleWorkspaceProviderStub(workspace: workspace)
        ).execute(
            CreateTaskRequest(
                title: "Plan work",
                durationMinutes: 60,
                categoryID: category.id,
                zoneID: morningZone.id,
                isSplittable: false,
                startsAt: date(hour: 9),
                selectedDay: date(hour: 0),
                timeZone: .gmt
            )
        )

        let capturedAddition = await repository.lastAddition()
        let addition = try XCTUnwrap(capturedAddition)
        XCTAssertEqual(addition.task.category, category)
        XCTAssertEqual(addition.sessionZoneID, morningZone.id)
    }

    func testCreateStandaloneTaskLeavesCategoryAndSessionZoneNil() async throws {
        let repository = TaskRepositoryStub(tasks: [])
        let workspace = ScheduleWorkspace(zones: [], goals: [], tasks: [], sessions: [])
        _ = try await DefaultCreateTaskUseCase(
            taskRepository: repository,
            workspaceProvider: ScheduleWorkspaceProviderStub(workspace: workspace)
        ).execute(
            CreateTaskRequest(
                title: "Standalone",
                durationMinutes: 30,
                zoneID: nil,
                isSplittable: false,
                startsAt: date(hour: 12),
                selectedDay: date(hour: 0),
                timeZone: .gmt
            )
        )

        let capturedAddition = await repository.lastAddition()
        let addition = try XCTUnwrap(capturedAddition)
        XCTAssertNil(addition.task.category)
        XCTAssertNil(addition.sessionZoneID)
    }

    func testUpdateTaskDerivesCategoryFromSelectedZone() async throws {
        let oldCategory = TaskCategory(id: UUID(), name: "Old")
        let newCategory = TaskCategory(id: UUID(), name: "Review")
        let task = try AwanTask(
            id: UUID(),
            title: "Draft",
            duration: TaskDuration(minutes: 60),
            isSplittable: false,
            category: oldCategory
        )
        let zone = try Zone(
            id: UUID(),
            name: "Evening Review",
            color: ZoneColor(hex: "#FF9800"),
            startTime: LocalTime(hour: 18, minute: 0),
            endTime: LocalTime(hour: 19, minute: 0),
            category: newCategory
        )
        let repository = TaskRepositoryStub(tasks: [task])
        let workspace = ScheduleWorkspace(
            zones: [zone],
            goals: [],
            tasks: [task],
            sessions: []
        )
        _ = try await DefaultUpdateTaskUseCase(
            workspaceProvider: ScheduleWorkspaceProviderStub(workspace: workspace),
            taskRepository: repository
        ).execute(
            UpdateTaskRequest(
                taskID: task.id,
                title: "Final",
                durationMinutes: 90,
                zoneID: zone.id,
                isSplittable: true,
                blocking: false,
                selectedDay: date(hour: 0),
                timeZone: .gmt
            )
        )

        let capturedUpdate = await repository.lastUpdate()
        let updated = try XCTUnwrap(capturedUpdate)
        XCTAssertEqual(updated.category, newCategory)
        XCTAssertEqual(updated.title, "Final")
        XCTAssertEqual(updated.duration.minutes, 90)
    }

    private func makeTask() throws -> AwanTask {
        try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
    }

    private func makeSession(
        taskID: UUID,
        startHour: Int = 10,
        blocking: Bool = false
    ) throws -> Session {
        Session(
            id: UUID(),
            taskID: taskID,
            zoneID: nil,
            timeRange: try TimeRange(
                start: date(hour: startHour),
                end: date(hour: startHour + 1)
            ),
            blocking: blocking,
            status: .planned
        )
    }

    private func makeProfile() throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "test@awan.app",
            firstName: "Test",
            lastName: "User",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 10,
            streak: 2,
            maxStreak: 3,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 8, minute: 0),
                sleepTime: try LocalTime(hour: 0, minute: 0)
            )
        )
    }

    private func date(hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar.date(
            from: DateComponents(year: 2026, month: 7, day: 22, hour: hour)
        ) ?? .distantPast
    }
}

private actor SessionRepositoryStub: SessionRepository {
    private var sessions: [Session]

    init(sessions: [Session]) {
        self.sessions = sessions
    }

    func values() -> [Session] { sessions }
    func fetchSessions() -> [Session] { sessions }
    func fetchSessions(for date: Date) -> [Session] { sessions }
    func addSession(_ session: Session) { sessions.append(session) }
    func updateSession(_ session: Session) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index] = session
    }
    func deleteSession(id: UUID) { sessions.removeAll { $0.id == id } }
    func deleteSessions(taskID: UUID) { sessions.removeAll { $0.taskID == taskID } }
    func deleteAllSessions() { sessions.removeAll() }
    func completeSession(id: UUID) async throws -> SessionCompletionResult {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else {
            fatalError("Session not found")
        }
        let old = sessions[index]
        let updated = Session(
            id: old.id,
            taskID: old.taskID,
            zoneID: old.zoneID,
            timeRange: old.timeRange,
            blocking: old.blocking,
            status: .completed,
            firstCompletedAt: old.firstCompletedAt ?? Date()
        )
        sessions[index] = updated
        let dummyReward = SessionCompletionReward(
            points: .init(awarded: true, amount: 10, oldValue: 0, newValue: 10),
            streak: .init(updated: false, oldValue: 0, newValue: 0, maxStreakBroken: false, maxStreakOld: 0, maxStreakNew: 0)
        )
        return SessionCompletionResult(
            session: updated,
            reward: dummyReward
        )
    }
    func uncompleteSession(id: UUID) async throws -> Session {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else {
            fatalError("Session not found")
        }
        let old = sessions[index]
        let updated = Session(
            id: old.id,
            taskID: old.taskID,
            zoneID: old.zoneID,
            timeRange: old.timeRange,
            blocking: old.blocking,
            status: .planned,
            firstCompletedAt: old.firstCompletedAt
        )
        sessions[index] = updated
        return updated
    }
}

private actor TaskRepositoryStub: TaskRepository {
    struct Addition: Sendable {
        let task: AwanTask
        let categoryID: UUID?
        let sessionZoneID: UUID?
        let startsAt: Date?
    }

    private var tasks: [AwanTask]
    private var addition: Addition?
    private var updatedTask: AwanTask?

    init(tasks: [AwanTask]) { self.tasks = tasks }
    func fetchTasks() -> [AwanTask] { tasks }
    func fetchInboxTasks() -> [AwanTask] { tasks }
    nonisolated func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    nonisolated func observeInboxTasks() -> AnyPublisher<[AwanTask], Error> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    func addTask(
        _ task: AwanTask,
        categoryID: UUID?,
        sessionZoneID: UUID?,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) -> (task: AwanTask, sessions: [Session]) {
        tasks.append(task)
        addition = Addition(
            task: task,
            categoryID: categoryID,
            sessionZoneID: sessionZoneID,
            startsAt: startsAt
        )
        return (task, [])
    }
    func updateTask(_ task: AwanTask) {
        updatedTask = task
    }
    func lastAddition() -> Addition? { addition }
    func lastUpdate() -> AwanTask? { updatedTask }
    func deleteTask(id: UUID) { tasks.removeAll { $0.id == id } }
    func deleteAllTasks() { tasks.removeAll() }
    func addDependency(taskID: UUID, dependsOnID: UUID) {}
    func removeDependency(taskID: UUID, dependsOnID: UUID) {}
    func fetchDependencies(taskID: UUID) -> [AwanTask] { [] }
    func fetchDependents(taskID: UUID) -> [AwanTask] { [] }
}

private struct ScheduleWorkspaceProviderStub: ScheduleWorkspaceProviding {
    let workspace: ScheduleWorkspace

    func load(for date: Date) async throws -> ScheduleWorkspace {
        workspace
    }
}

private actor UserProfileRepositoryStub: UserProfileRepository {
    let profile: UserProfile
    init(profile: UserProfile) { self.profile = profile }
    func fetchCurrentUser() -> UserProfile { profile }
    func updateProfile(firstName: String?, lastName: String?, birthDate: String?) {}
    func updateSessionDuration(_ durationMinutes: Int) -> UserProfile { profile }
    func updateTimezone(_ timezone: String) -> UserProfile { profile }
    func updateSleepSchedule(_ sleepTime: String) -> UserProfile { profile }
    func updateWakeUpSchedule(_ wakeUpTime: String) -> UserProfile { profile }
    func updateSleepSchedule(wakeUpTime: String, sleepTime: String) -> UserProfile {
        profile
    }
    func refreshGamificationProgress() async throws {}
}
