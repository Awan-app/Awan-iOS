import Domain
import Foundation
import XCTest
@testable import Presentation

@MainActor
final class CreateTaskViewModelTests: XCTestCase {
    func testLoadZonesPublishesAvailableZones() async throws {
        let zone = try makeZone()
        let stub = CreateTaskUseCaseStub(zones: [zone])
        let viewModel = makeViewModel(stub: stub)

        await viewModel.loadCreationData()

        XCTAssertEqual(viewModel.state.zones, [zone])
        let category = try XCTUnwrap(zone.category)
        XCTAssertEqual(viewModel.state.categories, [category])
        XCTAssertFalse(viewModel.state.isLoadingZones)
        XCTAssertNil(viewModel.state.errorMessage)
    }

    func testLoadZonesPublishesEachSharedCategoryOnce() async throws {
        let category = TaskCategory(id: UUID(), name: "Work")
        let morning = try makeZone(name: "Morning Work", category: category)
        let afternoon = try makeZone(name: "Afternoon Work", category: category)
        let stub = CreateTaskUseCaseStub(zones: [morning, afternoon])
        let viewModel = makeViewModel(stub: stub)

        await viewModel.loadCreationData()

        XCTAssertEqual(viewModel.state.categories, [category])
        XCTAssertEqual(viewModel.state.selectedCategoryID, category.id)
    }

    func testLoadCreationDataUsesPreferredSessionDuration() async {
        let stub = CreateTaskUseCaseStub(zones: [])
        let viewModel = makeViewModel(stub: stub)

        await viewModel.loadCreationData()

        XCTAssertEqual(viewModel.state.durationMinutes, 45)
    }

    func testManualSubmissionUsesSelectedStartAndPreferredDuration() async {
        let zone = try? makeZone()
        let stub = CreateTaskUseCaseStub(zones: zone.map { [$0] } ?? [])
        let viewModel = makeViewModel(stub: stub)
        let startsAt = date(hour: 14)

        await viewModel.loadCreationData()
        viewModel.state.isAwanSchedulingEnabled = false
        viewModel.state.quickText = "Read Clean Code"
        viewModel.state.startsAt = startsAt
        viewModel.state.selectedCategoryID = zone?.category?.id

        await viewModel.submitCurrentTask()

        let request = await stub.createdRequest()
        XCTAssertEqual(request?.title, "Read Clean Code")
        XCTAssertEqual(request?.durationMinutes, 45)
        XCTAssertEqual(request?.startsAt, startsAt)
        XCTAssertEqual(request?.categoryID, zone?.category?.id)
        XCTAssertNil(request?.zoneID)
    }

    func testCreateTaskBuildsRequestAndMarksCompletion() async throws {
        let zone = try makeZone()
        let stub = CreateTaskUseCaseStub(zones: [zone])
        let selectedDay = date(hour: 0)
        let startsAt = date(hour: 10)
        let viewModel = makeViewModel(
            stub: stub,
            selectedDay: selectedDay
        )

        await viewModel.createTask(
            title: "Read Clean Code",
            description: "Chapter one",
            durationMinutes: 60,
            categoryID: zone.category?.id,
            isSplittable: true,
            mandatory: true,
            startsAt: startsAt
        )

        let request = await stub.createdRequest()
        XCTAssertEqual(request?.title, "Read Clean Code")
        XCTAssertEqual(request?.description, "Chapter one")
        XCTAssertEqual(request?.durationMinutes, 60)
        XCTAssertEqual(request?.categoryID, zone.category?.id)
        XCTAssertNil(request?.zoneID)
        XCTAssertEqual(request?.startsAt, startsAt)
        XCTAssertEqual(request?.selectedDay, selectedDay)
        XCTAssertEqual(request?.estimatedPoints, 10)
        XCTAssertTrue(viewModel.state.didCreateTask)
        XCTAssertFalse(viewModel.state.isSubmitting)
        XCTAssertNil(viewModel.state.errorMessage)
    }

    func testCreateFailureKeepsSheetStateAvailableForRetry() async throws {
        let stub = CreateTaskUseCaseStub(zones: [], shouldFailCreation: true)
        let viewModel = makeViewModel(stub: stub)

        await viewModel.createTask(
            title: "Retry me",
            description: nil,
            durationMinutes: 30,
            categoryID: nil,
            isSplittable: false,
            mandatory: true,
            startsAt: date(hour: 9)
        )

        XCTAssertFalse(viewModel.state.didCreateTask)
        XCTAssertFalse(viewModel.state.isSubmitting)
        XCTAssertNotNil(viewModel.state.errorMessage)
    }

    func testReleasingRecordingPublishesTranscribedTaskText() async throws {
        let useCaseStub = CreateTaskUseCaseStub(zones: [])
        let speechStub = SpeechTranscriberStub(transcription: "Read Clean Code")
        let viewModel = makeViewModel(
            stub: useCaseStub,
            speechTranscriber: speechStub
        )

        await viewModel.beginRecording()
        XCTAssertTrue(viewModel.state.isRecording)

        await viewModel.finishRecording()

        XCTAssertFalse(viewModel.state.isRecording)
        XCTAssertEqual(viewModel.state.quickText, "Read Clean Code")
        XCTAssertEqual(speechStub.startCallCount, 1)
        XCTAssertEqual(speechStub.stopCallCount, 1)
    }

    func testReleasingRecordingUsesLatestPartialTranscriptionWhenFinalResultIsEmpty() async {
        let useCaseStub = CreateTaskUseCaseStub(zones: [])
        let speechStub = SpeechTranscriberStub(
            transcription: "",
            updateOnStart: "Read Clean Code"
        )
        let viewModel = makeViewModel(
            stub: useCaseStub,
            speechTranscriber: speechStub
        )

        await viewModel.beginRecording()
        await viewModel.finishRecording()

        XCTAssertEqual(viewModel.state.quickText, "Read Clean Code")
    }

    func testCreateTaskWithAwanUpdatesPhaseAndItemsInState() async throws {
        let stub = CreateTaskUseCaseStub(zones: [])
        let aiResponse = TaskProposal(sourceSummary: nil, tasks: [], timestamp: Date())
        let aiUseCase = CreateAITaskUseCaseStub(response: aiResponse)
        let viewModel = makeViewModel(stub: stub, aiUseCase: aiUseCase)

        await viewModel.createTaskWithAwan(prompt: "Study math")

        XCTAssertEqual(viewModel.state.phase, .aiTasksResult(aiResponse))
        XCTAssertFalse(viewModel.state.isSubmitting)
    }

    func testDismissAITaskResultResetsState() async throws {
        let stub = CreateTaskUseCaseStub(zones: [])
        let aiResponse = TaskProposal(sourceSummary: nil, tasks: [], timestamp: Date())
        let aiUseCase = CreateAITaskUseCaseStub(response: aiResponse)
        let viewModel = makeViewModel(stub: stub, aiUseCase: aiUseCase)

        await viewModel.createTaskWithAwan(prompt: "Study math")
        XCTAssertEqual(viewModel.state.phase, .aiTasksResult(aiResponse))

        viewModel.dismissAITaskResult()

        XCTAssertEqual(viewModel.state.phase, .composer)
    }

    private func makeViewModel(
        stub: CreateTaskUseCaseStub,
        aiUseCase: CreateAITaskUseCase? = nil,
        selectedDay: Date? = nil,
        speechTranscriber: SpeechTranscriberStub? = nil
    ) -> CreateTaskViewModel {
        CreateTaskViewModel(
            useCases: CreationUseCases(
                fetchZones: stub,
                createTask: stub,
                createAITask: aiUseCase ?? MockCreateAITaskUseCase(),
                imageToTasks: MockImageToTasksUseCase(),
                acceptProposedTask: MockAcceptProposedTaskUseCase(),
                userProfile: UserProfileUseCaseStub(),
                goalDecomposition: GoalDecompositionUseCases(
                    sendMessage: GoalMessageUseCaseStub(),
                    confirmProposal: GoalConfirmUseCaseStub(),
                    scheduleGoal: GoalScheduleUseCaseStub()
                )
            ),
            speechTranscriber: speechTranscriber ?? SpeechTranscriberStub(),
            selectedDay: selectedDay ?? date(hour: 0),
            timeZone: TimeZone(secondsFromGMT: 0) ?? .gmt
        )
    }

    private func makeZone(
        name: String = "Learning",
        category: TaskCategory? = TaskCategory(id: UUID(), name: "Learning")
    ) throws -> Zone {
        try Zone(
            id: UUID(),
            name: name,
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 12, minute: 0),
            category: category
        )
    }

    private func date(hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 24,
                hour: hour
            )
        ) ?? .distantPast
    }
}

private struct GoalMessageUseCaseStub: SendGoalDecompositionMessageUseCase {
    func execute(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse {
        GoalDecompositionResponse(
            sessionID: UUID(),
            blocks: [],
            hasProposal: false
        )
    }
}

private struct GoalConfirmUseCaseStub: ConfirmGoalProposalUseCase {
    func execute(sessionID: UUID) async throws -> ConfirmedGoal {
        ConfirmedGoal(id: UUID(), title: "")
    }
}

private struct GoalScheduleUseCaseStub: ScheduleCreatedGoalUseCase {
    func execute(goalID: UUID) async throws {}
}

private struct UserProfileUseCaseStub: GetUserProfileUseCase {
    func execute() async throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "reader@awan.app",
            firstName: "Awan",
            lastName: "Reader",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 45,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 7, minute: 0),
                sleepTime: try LocalTime(hour: 23, minute: 0)
            )
        )
    }
}

@MainActor
private final class SpeechTranscriberStub: SpeechTranscribing {
    private let transcription: String
    private let updateOnStart: String?
    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    init(
        transcription: String = "",
        updateOnStart: String? = nil
    ) {
        self.transcription = transcription
        self.updateOnStart = updateOnStart
    }

    func startTranscribing(
        onUpdate: @escaping (String) -> Void
    ) async throws {
        startCallCount += 1
        if let updateOnStart {
            onUpdate(updateOnStart)
        }
    }

    func stopTranscribing() async -> String {
        stopCallCount += 1
        return transcription
    }

    func cancelTranscribing() {}
}

private enum CreateTaskStubError: Error {
    case failed
}

private actor CreateTaskUseCaseStub: FetchZonesUseCase, CreateTaskUseCase {
    private let zones: [Zone]
    private let shouldFailCreation: Bool
    private var request: CreateTaskRequest?

    init(zones: [Zone], shouldFailCreation: Bool = false) {
        self.zones = zones
        self.shouldFailCreation = shouldFailCreation
    }

    func execute(for date: Date) async throws -> [Zone] {
        zones
    }

    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        if shouldFailCreation {
            throw CreateTaskStubError.failed
        }
        self.request = request
        return ScheduleOperationResult(
            workspace: ScheduleWorkspace(
                zones: zones,
                goals: [],
                tasks: [],
                sessions: []
            ),
            nudge: nil
        )
    }

    func createdRequest() -> CreateTaskRequest? {
        request
    }
}

private struct MockImageToTasksUseCase: ImageToTasksUseCase {
    func execute(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposal {
        TaskProposal(sourceSummary: "Test Summary", tasks: [], timestamp: Date())
    }
}

private struct MockAcceptProposedTaskUseCase: AcceptProposedTaskUseCase {
    func execute(_ draft: TaskWithSessionsDraft) async throws -> AwanTask {
        AwanTask(
            id: UUID(),
            title: draft.task.title,
            description: draft.task.description,
            status: .pending,
            goalID: draft.task.goalId,
            duration: try! TaskDuration(minutes: draft.task.estimatedDuration),
            isSplittable: draft.task.allowTaskSplitting,
            mandatory: draft.task.mandatory,
            estimatedPoints: draft.task.estimatedPoints,
            dependencyIDs: [],
            category: nil
        )
    }
}
private struct CreateAITaskUseCaseStub: CreateAITaskUseCase {
    let response: TaskProposal
    func execute(_ request: CreateAITaskRequest) async throws -> TaskProposal {
        response
    }
}
