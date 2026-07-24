import Domain
import Foundation
import XCTest
@testable import Presentation

@MainActor
final class HomeViewModelTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testLoadPublishesProfileSummaryAndTimeline() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        XCTAssertEqual(viewModel.state.success?.tasks.map(\.id), [fixture.task.id])
        XCTAssertEqual(viewModel.state.success?.sessions.map(\.id), [fixture.session.id])
        XCTAssertEqual(viewModel.state.success?.zones.map(\.id), [fixture.zone.id])
        XCTAssertEqual(viewModel.state.success?.profile.id, fixture.profile.id)
        XCTAssertEqual(viewModel.state.success?.displayName, "Sam")
        XCTAssertEqual(viewModel.state.success?.streakCount, 4)
        XCTAssertEqual(viewModel.state.success?.rewardPoints, 100)
        XCTAssertEqual(viewModel.state.success?.taskCount, 1)
        XCTAssertEqual(viewModel.state.success?.scheduledMinutes, 60)
        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.title, "Focus")
    }

    func testDragSnapsToQuarterHourAndLocksSession() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .moveSession(
                sessionID: fixture.session.id,
                verticalPoints: HomeDayTimelineView.hourHeight * 0.4,
                hourHeight: HomeDayTimelineView.hourHeight
            )
        )
        await waitUntil { viewModel.state.success?.timelineItems.first?.blocking == true }

        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.start, date(hour: 10, minute: 30))
        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.durationMinutes, 60)
    }

    func testDragUpdatesImmediatelyBeforeRescheduleFinishes() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture, mutationDelay: .milliseconds(200))
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .moveSession(
                sessionID: fixture.session.id,
                verticalPoints: HomeDayTimelineView.hourHeight * 0.4,
                hourHeight: HomeDayTimelineView.hourHeight
            )
        )

        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.start, date(hour: 10, minute: 30))
        XCTAssertTrue(viewModel.state.success?.timelineItems.first?.blocking == true)
        XCTAssertTrue(viewModel.state.isMutating)
        await waitUntil { viewModel.state.isMutating == false }
    }

    func testFailedOptimisticDragRollsBackToOriginalSession() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(
            fixture: fixture,
            mutationDelay: .milliseconds(40),
            shouldFailReschedule: true
        )
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .moveSession(
                sessionID: fixture.session.id,
                verticalPoints: HomeDayTimelineView.hourHeight,
                hourHeight: HomeDayTimelineView.hourHeight
            )
        )
        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.start, date(hour: 11))

        await waitUntil { viewModel.state.isMutating == false }

        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.start, date(hour: 10))
        XCTAssertFalse(viewModel.state.success?.timelineItems.first?.blocking == true)
        XCTAssertNotNil(viewModel.state.failure)
    }

    func testDragClampsSessionToAwakeWindow() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .moveSession(
                sessionID: fixture.session.id,
                verticalPoints: HomeDayTimelineView.hourHeight * 20,
                hourHeight: HomeDayTimelineView.hourHeight
            )
        )
        await waitUntil { viewModel.state.success?.timelineItems.first?.blocking == true }

        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.start, date(day: 23, hour: 0))
        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.end, date(day: 23, hour: 1))
    }

    func testDeleteRemovesSessionButLeavesTaskInUseCaseStorage() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(.deleteSession(fixture.session.id))
        await waitUntil {
            viewModel.state.success?.timelineItems.isEmpty == true && !viewModel.state.isMutating
        }

        let taskCount = await stub.taskCount()
        let sessionCount = await stub.sessionCount()
        XCTAssertEqual(taskCount, 1)
        XCTAssertEqual(sessionCount, 0)
    }

    func testFailedOptimisticDeleteRestoresSession() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(
            fixture: fixture,
            mutationDelay: .milliseconds(40),
            shouldFailDelete: true
        )
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(.deleteSession(fixture.session.id))
        XCTAssertTrue(viewModel.state.success?.sessions.isEmpty == true)

        await waitUntil { !viewModel.state.isMutating }

        XCTAssertEqual(viewModel.state.success?.sessions, [fixture.session])
        XCTAssertNotNil(viewModel.state.failure)
    }

    func testExplicitLockActionUpdatesTimelineItem() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(.setSessionLock(sessionID: fixture.session.id, isLocked: true))
        await waitUntil { viewModel.state.success?.timelineItems.first?.blocking == true }

        XCTAssertTrue(viewModel.state.success?.timelineItems.first?.blocking == true)
    }

    func testCompletionButtonUpdatesSessionAndSummaryOptimistically() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .setSessionCompletion(sessionID: fixture.session.id, isCompleted: true)
        )

        XCTAssertEqual(viewModel.state.success?.timelineItems.first?.status, .completed)
        XCTAssertEqual(viewModel.state.success?.completedSessionCount, 1)
        await waitUntil { viewModel.state.isMutating == false }
    }

    func testSelectingDayCancelsStaleLoadAndPublishesLatestDay() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture, readDelay: .milliseconds(60))
        let viewModel = makeViewModel(stub: stub)
        let nextDay = date(day: 23)

        viewModel.send(.appeared)
        viewModel.send(.selectDay(nextDay))
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        XCTAssertEqual(viewModel.state.selectedDay, nextDay)
        XCTAssertTrue(viewModel.state.success?.timelineItems.isEmpty == true)
    }

    func testLoadFailurePublishesRetryableFailure() async throws {
        let stub = HomeUseCaseStub(fixture: try HomeFixture(), shouldFailReads: true)
        let viewModel = makeViewModel(stub: stub)

        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.failure != nil }

        XCTAssertNotNil(viewModel.state.failure)
        XCTAssertNil(viewModel.state.success)
    }

    func testCreateTaskWithNudgeSetsActiveNudge() async throws {
        let fixture = try HomeFixture()
        let stub = HomeUseCaseStub(fixture: fixture, shouldReturnNudgeOnCreate: true)
        let viewModel = makeViewModel(stub: stub)
        viewModel.send(.appeared)
        await waitUntil { !viewModel.state.isLoading && viewModel.state.success != nil }

        viewModel.send(
            .createTask(
                title: "Test",
                description: nil,
                durationMinutes: 60,
                zoneID: nil,
                isSplittable: true,
                mandatory: true,
                startsAt: nil
            )
        )

        await waitUntil { viewModel.state.activeNudge != nil }
        XCTAssertNotNil(viewModel.state.activeNudge)

        viewModel.send(.dismissNudge)
        XCTAssertNil(viewModel.state.activeNudge)
    }

    private func makeViewModel(stub: HomeUseCaseStub) -> HomeViewModel {
        HomeViewModel(
            useCases: HomeUseCases(
                reads: HomeReadUseCases(
                    tasks: stub,
                    sessions: stub,
                    zones: stub,
                    userProfile: stub
                ),
                sessions: HomeSessionUseCases(
                    reschedule: stub,
                    setLock: stub,
                    setCompletion: stub,
                    delete: stub
                ),
                createTask: stub
            ),
            selectedDay: date(),
            timeZone: timeZone
        )
    }

    private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func date(day: Int = 22, hour: Int = 0, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: day,
                hour: hour,
                minute: minute
            )
        ) ?? .distantPast
    }
}

private struct HomeFixture {
    let task: AwanTask
    let session: Session
    let zone: Zone
    let profile: UserProfile

    init() throws {
        let zone = try Zone(
            id: UUID(),
            name: "Work",
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 1, minute: 0)
        )
        let task = try AwanTask(
            id: UUID(),
            title: "Focus",
            zoneID: zone.id,
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let start = calendar.date(
            from: DateComponents(year: 2026, month: 7, day: 22, hour: 10)
        ) ?? .distantPast
        let session = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: zone.id,
            timeRange: try TimeRange(start: start, end: start.addingTimeInterval(60 * 60)),
            blocking: false,
            status: .planned
        )
        let profile = UserProfile(
            id: UUID(),
            email: "home@awan.app",
            firstName: "Sam",
            lastName: "Nour",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 100,
            streak: 4,
            maxStreak: 7,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 8, minute: 0),
                sleepTime: try LocalTime(hour: 1, minute: 0)
            )
        )
        self.task = task
        self.session = session
        self.zone = zone
        self.profile = profile
    }
}

private enum HomeStubError: Error {
    case failed
}

private actor HomeUseCaseStub:
    FetchTasksUseCase,
    FetchSessionsUseCase,
    FetchZonesUseCase,
    GetUserProfileUseCase,
    RescheduleSessionUseCase,
    SetSessionLockUseCase,
    SetSessionCompletionUseCase,
    DeleteSessionUseCase,
    CreateTaskUseCase {
    private var tasks: [AwanTask]
    private var sessions: [Session]
    private let zones: [Zone]
    private let profile: UserProfile
    private let shouldFailReads: Bool
    private let readDelay: Duration?
    private let mutationDelay: Duration?
    private let shouldFailReschedule: Bool
    private let shouldFailDelete: Bool
    private let shouldReturnNudgeOnCreate: Bool

    init(
        fixture: HomeFixture,
        shouldFailReads: Bool = false,
        readDelay: Duration? = nil,
        mutationDelay: Duration? = nil,
        shouldFailReschedule: Bool = false,
        shouldFailDelete: Bool = false,
        shouldReturnNudgeOnCreate: Bool = false
    ) {
        tasks = [fixture.task]
        sessions = [fixture.session]
        zones = [fixture.zone]
        profile = fixture.profile
        self.shouldFailReads = shouldFailReads
        self.readDelay = readDelay
        self.mutationDelay = mutationDelay
        self.shouldFailReschedule = shouldFailReschedule
        self.shouldFailDelete = shouldFailDelete
        self.shouldReturnNudgeOnCreate = shouldReturnNudgeOnCreate
    }

    func execute() async throws -> [AwanTask] {
        try await pause()
        if shouldFailReads { throw HomeStubError.failed }
        return tasks
    }

    func execute() async throws -> [Session] {
        try await pause()
        if shouldFailReads { throw HomeStubError.failed }
        return sessions
    }

    func execute(for date: Date) async throws -> [Zone] {
        try await pause()
        if shouldFailReads { throw HomeStubError.failed }
        return zones
    }

    func execute() async throws -> UserProfile {
        try await pause()
        if shouldFailReads { throw HomeStubError.failed }
        return profile
    }

    func execute(sessionID: UUID, newStart: Date) async throws -> Session {
        if let mutationDelay {
            try await Task.sleep(for: mutationDelay)
        }
        if shouldFailReschedule { throw HomeStubError.failed }
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            throw HomeStubError.failed
        }
        let existing = sessions[index]
        let updated = Session(
            id: existing.id,
            taskID: existing.taskID,
            zoneID: existing.zoneID,
            timeRange: try TimeRange(
                start: newStart,
                end: newStart.addingTimeInterval(existing.timeRange.end.timeIntervalSince(existing.timeRange.start))
            ),
            blocking: true,
            status: existing.status
        )
        sessions[index] = updated
        return updated
    }

    func execute(sessionID: UUID, isLocked: Bool) throws -> Session {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            throw HomeStubError.failed
        }
        let existing = sessions[index]
        let updated = Session(
            id: existing.id,
            taskID: existing.taskID,
            zoneID: existing.zoneID,
            timeRange: existing.timeRange,
            blocking: isLocked,
            status: existing.status
        )
        sessions[index] = updated
        return updated
    }

    func execute(sessionID: UUID, isCompleted: Bool) throws -> Session {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            throw HomeStubError.failed
        }
        let existing = sessions[index]
        let updated = Session(
            id: existing.id,
            taskID: existing.taskID,
            zoneID: existing.zoneID,
            timeRange: existing.timeRange,
            blocking: existing.blocking,
            status: isCompleted ? .completed : .planned
        )
        sessions[index] = updated
        return updated
    }

    func execute(sessionID: UUID) async throws {
        if let mutationDelay {
            try await Task.sleep(for: mutationDelay)
        }
        if shouldFailDelete { throw HomeStubError.failed }
        sessions.removeAll { $0.id == sessionID }
    }

    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        if let mutationDelay {
            try await Task.sleep(for: mutationDelay)
        }
        let task = try AwanTask(
            id: UUID(),
            title: request.title,
            description: request.description,
            zoneID: request.zoneID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory
        )
        tasks.append(task)
        let workspace = ScheduleWorkspace(
            zones: zones,
            goals: [],
            tasks: tasks,
            sessions: sessions
        )
        let nudge = shouldReturnNudgeOnCreate ? ScheduleNudge.schedulingIssue(
            SchedulingIssue(
                taskID: task.id,
                reason: .insufficientZoneTime,
                requiredMinutes: request.durationMinutes,
                availableMinutes: 0,
                resolutionCandidates: []
            )
        ) : nil
        return ScheduleOperationResult(workspace: workspace, nudge: nudge)
    }

    func taskCount() -> Int { tasks.count }
    func sessionCount() -> Int { sessions.count }

    private func pause() async throws {
        if let readDelay {
            try await Task.sleep(for: readDelay)
        }
    }
}
