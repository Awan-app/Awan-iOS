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

        let tasks = try await DefaultFetchTasksUseCase(repository: taskRepository).execute()
        let sessions = try await DefaultFetchSessionsUseCase(repository: sessionRepository).execute()
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
        let repository = SessionRepositoryStub(sessions: [session])

        let completed = try await DefaultSetSessionCompletionUseCase(repository: repository)
            .execute(sessionID: session.id, isCompleted: true)

        XCTAssertEqual(completed.status, .completed)
        XCTAssertEqual(completed.timeRange, session.timeRange)
        XCTAssertEqual(completed.blocking, session.blocking)

        let planned = try await DefaultSetSessionCompletionUseCase(repository: repository)
            .execute(sessionID: session.id, isCompleted: false)
        XCTAssertEqual(planned.status, .planned)
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
    func addSession(_ session: Session) { sessions.append(session) }
    func updateSession(_ session: Session) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index] = session
    }
    func deleteSession(id: UUID) { sessions.removeAll { $0.id == id } }
    func deleteSessions(taskID: UUID) { sessions.removeAll { $0.taskID == taskID } }
    func deleteAllSessions() { sessions.removeAll() }
}

private actor TaskRepositoryStub: TaskRepository {
    private var tasks: [AwanTask]

    init(tasks: [AwanTask]) { self.tasks = tasks }
    func fetchTasks() -> [AwanTask] { tasks }
    func addTask(
        _ task: AwanTask,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) -> (task: AwanTask, sessions: [Session]) {
        tasks.append(task)
        return (task, [])
    }
    func updateTask(_ task: AwanTask) {}
    func deleteTask(id: UUID) { tasks.removeAll { $0.id == id } }
    func deleteAllTasks() { tasks.removeAll() }
    func addDependency(taskID: UUID, dependsOnID: UUID) {}
    func removeDependency(taskID: UUID, dependsOnID: UUID) {}
    func fetchDependencies(taskID: UUID) -> [AwanTask] { [] }
    func fetchDependents(taskID: UUID) -> [AwanTask] { [] }
}

private actor UserProfileRepositoryStub: UserProfileRepository {
    let profile: UserProfile
    init(profile: UserProfile) { self.profile = profile }
    func fetchCurrentUser() -> UserProfile { profile }
}
