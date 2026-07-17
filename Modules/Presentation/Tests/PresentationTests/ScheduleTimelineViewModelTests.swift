import Domain
import Foundation
import XCTest
@testable import Presentation

@MainActor
final class ScheduleTimelineViewModelTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testLoadPublishesSingleReadyUIState() async throws {
        let workspace = try makeWorkspace()
        let viewModel = makeViewModel(useCase: ScheduleUseCaseStub(workspace: workspace))

        viewModel.send(.appeared)
        await waitUntil { viewModel.state.status == .ready }

        XCTAssertEqual(viewModel.state.status, .ready)
        XCTAssertEqual(viewModel.state.weekDays.count, 7)
        XCTAssertEqual(viewModel.state.zoneOptions.map(\.name), ["Work"])
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNil(viewModel.state.errorMessage)
    }

    func testLoadExposesLoadingThenReadyState() async throws {
        let workspace = try makeWorkspace()
        let viewModel = makeViewModel(
            useCase: ScheduleUseCaseStub(workspace: workspace, loadDelay: .milliseconds(80))
        )

        viewModel.send(.appeared)
        await Task.yield()

        XCTAssertEqual(viewModel.state.status, .loading)

        await waitUntil { viewModel.state.status == .ready }
        XCTAssertEqual(viewModel.state.status, .ready)
    }

    func testSheetStateOnlyChangesThroughViewModelFunctions() async throws {
        let viewModel = makeViewModel(
            useCase: ScheduleUseCaseStub(workspace: try makeWorkspace())
        )

        viewModel.send(.presentCreateTask)
        XCTAssertEqual(viewModel.state.presentedSheet, .createTask)

        viewModel.send(.dismissSheet)
        XCTAssertNil(viewModel.state.presentedSheet)

        viewModel.send(.presentCreateGoal)
        XCTAssertEqual(viewModel.state.presentedSheet, .createGoal)
    }

    func testOverlapScenarioMapsDomainNudgeToGamifiedActions() async throws {
        let workspace = try makeWorkspace()
        let result = ScheduleOperationResult(
            workspace: workspace,
            nudge: .overlap(firstSessionID: UUID(), secondSessionID: UUID())
        )
        let viewModel = makeViewModel(
            useCase: ScheduleUseCaseStub(workspace: workspace, simulatedResult: result)
        )

        viewModel.send(.simulate(.overlap))
        await waitUntil { viewModel.state.activeNudge != nil }

        XCTAssertEqual(viewModel.state.activeNudge?.title, "Power combo detected!")
        XCTAssertEqual(
            viewModel.state.activeNudge?.actions.map(\.title),
            ["Keep overlap", "Separate", "Move second"]
        )
    }

    func testTaskUpdatePublishesReconciledTimelineStateAndRequest() async throws {
        let original = try makeWorkspace(title: "Draft", taskMinutes: 60, sessionMinutes: 60)
        let updated = try makeWorkspace(title: "Polished", taskMinutes: 210, sessionMinutes: 210)
        let stub = ScheduleUseCaseStub(
            workspace: original,
            updatedResult: ScheduleOperationResult(workspace: updated, nudge: nil)
        )
        let viewModel = makeViewModel(useCase: stub)
        viewModel.send(.appeared)
        await waitUntil { viewModel.state.status == .ready }
        let taskID = try XCTUnwrap(original.tasks.first?.id)
        let zoneID = try XCTUnwrap(original.zones.first?.id)

        viewModel.send(
            .updateTask(
                taskID: taskID,
                submission: ScheduleTaskSubmission(
                    title: "Polished",
                    durationMinutes: 210,
                    zoneID: zoneID,
                    isSplittable: true
                )
            )
        )
        await waitUntil { viewModel.state.timelineItems.first?.durationMinutes == 210 }

        XCTAssertEqual(viewModel.state.timelineItems.first?.title, "Polished")
        XCTAssertEqual(viewModel.state.timelineItems.first?.durationMinutes, 210)
        XCTAssertEqual(viewModel.state.taskEditorsByID[taskID]?.durationMinutes, 210)
        let request = await stub.lastUpdateRequest
        XCTAssertEqual(request?.taskID, taskID)
        XCTAssertEqual(request?.durationMinutes, 210)
        XCTAssertEqual(request?.selectedDay, date(day: 20))
    }

    func testFailureIsContainedInUnifiedStateAndDismissedThroughFunction() async throws {
        let viewModel = makeViewModel(
            useCase: ScheduleUseCaseStub(
                workspace: try makeWorkspace(),
                loadError: StubError.failed
            )
        )

        viewModel.send(.appeared)
        await waitUntil { viewModel.state.status == .ready }

        XCTAssertEqual(viewModel.state.status, .ready)
        XCTAssertNotNil(viewModel.state.errorMessage)

        viewModel.send(.dismissError)
        XCTAssertNil(viewModel.state.errorMessage)
    }

    private func makeViewModel(useCase: ScheduleUseCaseStub) -> ScheduleTimelineViewModel {
        ScheduleTimelineViewModel(
            useCases: makeUseCases(stub: useCase),
            selectedDay: date(day: 20),
            timeZone: timeZone
        )
    }

    private func makeUseCases(stub: ScheduleUseCaseStub) -> ScheduleTimelineUseCases {
        ScheduleTimelineUseCases(
            workspace: stub,
            tasks: ScheduleTaskUseCases(create: stub, update: stub, delete: stub),
            goals: ScheduleGoalUseCases(createSevenTaskGoal: stub),
            sessions: ScheduleSessionUseCases(move: stub),
            conflicts: ScheduleConflictUseCases(
                applyCandidate: stub,
                separateOverlap: stub,
                moveOverlap: stub,
                shiftGoalChain: stub,
                stackTasks: stub,
                makeTaskIndependent: stub,
                replanZoneSessions: stub,
                restoreZone: stub,
                keepFixedOverAllocation: stub,
                trimFixedOverAllocation: stub,
                keepFixedSessionsOutsideZone: stub,
                moveFixedSessionsIntoZone: stub,
                restoreTaskZone: stub
            ),
            simulation: ScheduleSimulationUseCases(simulate: stub, reset: stub)
        )
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool
    ) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func makeWorkspace(
        title: String = "Draft",
        taskMinutes: Int? = nil,
        sessionMinutes: Int = 60
    ) throws -> ScheduleWorkspace {
        let zone = try Zone(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010") ?? UUID(),
            name: "Work",
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        guard let taskMinutes else {
            return ScheduleWorkspace(zones: [zone], goals: [], tasks: [], sessions: [])
        }
        let task = try AwanTask(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020") ?? UUID(),
            title: title,
            zoneID: zone.id,
            duration: TaskDuration(minutes: taskMinutes),
            isSplittable: true
        )
        let start = date(day: 20, hour: 9)
        let session = Session(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000030") ?? UUID(),
            taskID: task.id,
            zoneID: zone.id,
            timeRange: try TimeRange(
                start: start,
                end: start.addingTimeInterval(TimeInterval(sessionMinutes * 60))
            ),
            placement: .engineManaged,
            status: .planned
        )
        return ScheduleWorkspace(zones: [zone], goals: [], tasks: [task], sessions: [session])
    }

    private func date(day: Int, hour: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(year: 2026, month: 7, day: day, hour: hour)
        ) ?? .distantPast
    }
}

private enum StubError: Error {
    case failed
}

private actor ScheduleUseCaseStub:
    LoadScheduleWorkspaceUseCase,
    CreateTaskUseCase,
    UpdateTaskUseCase,
    DeleteTaskUseCase,
    CreateSevenTaskGoalUseCase,
    MoveSessionUseCase,
    ApplyScheduleCandidateUseCase,
    SeparateOverlappingSessionsUseCase,
    MoveOverlappingSessionUseCase,
    ShiftGoalDependencyChainUseCase,
    StackDependentTasksUseCase,
    MakeTaskIndependentUseCase,
    ReplanZoneSessionsUseCase,
    RestoreZoneUseCase,
    KeepFixedOverAllocationUseCase,
    TrimFixedOverAllocationUseCase,
    KeepFixedSessionsOutsideZoneUseCase,
    MoveFixedSessionsIntoZoneUseCase,
    RestoreTaskZoneUseCase,
    SimulateScheduleScenarioUseCase,
    ResetScheduleSimulationUseCase {
    private let workspace: ScheduleWorkspace
    private let simulatedResult: ScheduleOperationResult?
    private let updatedResult: ScheduleOperationResult?
    private let loadDelay: Duration?
    private let loadError: StubError?
    private(set) var lastUpdateRequest: UpdateTaskRequest?

    init(
        workspace: ScheduleWorkspace,
        simulatedResult: ScheduleOperationResult? = nil,
        updatedResult: ScheduleOperationResult? = nil,
        loadDelay: Duration? = nil,
        loadError: StubError? = nil
    ) {
        self.workspace = workspace
        self.simulatedResult = simulatedResult
        self.updatedResult = updatedResult
        self.loadDelay = loadDelay
        self.loadError = loadError
    }

    func execute() async throws -> ScheduleWorkspace {
        if let loadDelay { try await Task.sleep(for: loadDelay) }
        if let loadError { throw loadError }
        return workspace
    }

    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult {
        lastUpdateRequest = request
        return updatedResult ?? ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(taskID: UUID) async throws -> ScheduleWorkspace { workspace }

    func execute(
        _ request: CreateSevenTaskGoalRequest
    ) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: MoveSessionRequest) async throws -> ScheduleWorkspace { workspace }

    func execute(
        _ scenario: ScheduleSimulationScenario,
        on selectedDay: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        simulatedResult ?? ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ candidate: ResolutionCandidate) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: OverlappingSessionsRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(
        _ request: ShiftGoalDependencyChainRequest
    ) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: StackDependentTasksRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: MakeTaskIndependentRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: ReplanZoneSessionsRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ zone: Zone) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: FixedOverAllocationRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(
        _ request: KeepFixedSessionsOutsideZoneRequest
    ) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(
        _ request: MoveFixedSessionsIntoZoneRequest
    ) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }

    func execute(_ request: RestoreTaskZoneRequest) async throws -> ScheduleOperationResult {
        ScheduleOperationResult(workspace: workspace, nudge: nil)
    }
}
