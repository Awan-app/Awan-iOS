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

        await viewModel.loadZones()

        XCTAssertEqual(viewModel.zones, [zone])
        XCTAssertFalse(viewModel.isLoadingZones)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadCreationDataUsesPreferredSessionDuration() async {
        let stub = CreateTaskUseCaseStub(zones: [])
        let viewModel = makeViewModel(stub: stub)

        await viewModel.loadCreationData()

        XCTAssertEqual(viewModel.durationMinutes, 45)
    }

    func testManualSubmissionUsesSelectedStartAndPreferredDuration() async {
        let stub = CreateTaskUseCaseStub(zones: [])
        let viewModel = makeViewModel(stub: stub)
        let startsAt = date(hour: 14)

        await viewModel.loadCreationData()
        viewModel.isAwanSchedulingEnabled = false
        viewModel.quickText = "Read Clean Code"
        viewModel.startsAt = startsAt

        await viewModel.submitCurrentTask()

        let request = await stub.createdRequest()
        XCTAssertEqual(request?.title, "Read Clean Code")
        XCTAssertEqual(request?.durationMinutes, 45)
        XCTAssertEqual(request?.startsAt, startsAt)
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
            zoneID: zone.id,
            isSplittable: true,
            mandatory: true,
            startsAt: startsAt
        )

        let request = await stub.createdRequest()
        XCTAssertEqual(request?.title, "Read Clean Code")
        XCTAssertEqual(request?.description, "Chapter one")
        XCTAssertEqual(request?.durationMinutes, 60)
        XCTAssertEqual(request?.zoneID, zone.id)
        XCTAssertEqual(request?.startsAt, startsAt)
        XCTAssertEqual(request?.selectedDay, selectedDay)
        XCTAssertEqual(request?.estimatedPoints, 10)
        XCTAssertTrue(viewModel.didCreateTask)
        XCTAssertFalse(viewModel.isSubmitting)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testCreateFailureKeepsSheetStateAvailableForRetry() async throws {
        let stub = CreateTaskUseCaseStub(zones: [], shouldFailCreation: true)
        let viewModel = makeViewModel(stub: stub)

        await viewModel.createTask(
            title: "Retry me",
            description: nil,
            durationMinutes: 30,
            zoneID: nil,
            isSplittable: false,
            mandatory: true,
            startsAt: date(hour: 9)
        )

        XCTAssertFalse(viewModel.didCreateTask)
        XCTAssertFalse(viewModel.isSubmitting)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testReleasingRecordingPublishesTranscribedTaskText() async throws {
        let useCaseStub = CreateTaskUseCaseStub(zones: [])
        let speechStub = SpeechTranscriberStub(transcription: "Read Clean Code")
        let viewModel = makeViewModel(
            stub: useCaseStub,
            speechTranscriber: speechStub
        )

        await viewModel.beginRecording()
        XCTAssertTrue(viewModel.isRecording)

        await viewModel.finishRecording()

        XCTAssertFalse(viewModel.isRecording)
        XCTAssertEqual(viewModel.quickText, "Read Clean Code")
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

        XCTAssertEqual(viewModel.quickText, "Read Clean Code")
    }

    private func makeViewModel(
        stub: CreateTaskUseCaseStub,
        selectedDay: Date? = nil,
        speechTranscriber: SpeechTranscriberStub? = nil
    ) -> CreateTaskViewModel {
        CreateTaskViewModel(
            useCases: CreationUseCases(
                fetchZones: stub,
                createTask: stub,
                createTaskWithAwan: EmptyCreateTaskWithAwanUseCase(),
                userProfile: UserProfileUseCaseStub()
            ),
            speechTranscriber: speechTranscriber ?? SpeechTranscriberStub(),
            selectedDay: selectedDay ?? date(hour: 0),
            timeZone: TimeZone(secondsFromGMT: 0) ?? .gmt
        )
    }

    private func makeZone() throws -> Zone {
        try Zone(
            id: UUID(),
            name: "Learning",
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 12, minute: 0)
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
