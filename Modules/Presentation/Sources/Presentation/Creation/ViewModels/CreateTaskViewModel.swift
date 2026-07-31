import Domain
import Foundation
import Observation

@Observable
@MainActor
final class CreateTaskViewModel {
    var state: CreateTaskState
public enum CreateTaskPhase: Equatable {
    case composer
    case aiLoading
    case aiResult([AITaskSheetItem])
}

@Observable
@MainActor
public final class CreateTaskViewModel {
    public private(set) var zones: [Zone] = []
    public private(set) var isLoadingZones = false
    public private(set) var isSubmitting = false
    public private(set) var errorMessage: String?
    public private(set) var didCreateTask = false
    public private(set) var activeNudge: ScheduleNudge?
    private(set) var phase: CreateTaskPhase = .composer
    private(set) var pendingAITaskItems: [AITaskSheetItem] = []
    var quickText = ""
    var isAwanSchedulingEnabled = true
    var durationMinutes = 60
    var startsAt: Date
    var selectedZoneID: UUID?
    private(set) var isRecording = false

    private let selectedDay: Date

    @ObservationIgnored let useCases: CreationUseCases
    @ObservationIgnored let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored private let timeZone: TimeZone
    @ObservationIgnored private var didLoadZones = false
    @ObservationIgnored var wantsToRecord = false
    @ObservationIgnored var pendingTranscription = ""

    init(
        useCases: CreationUseCases,
        speechTranscriber: any SpeechTranscribing,
        selectedDay: Date = Date(),
        timeZone: TimeZone = .current
    ) {
        self.useCases = useCases
        self.speechTranscriber = speechTranscriber
        self.selectedDay = selectedDay
        self.timeZone = timeZone
        self.state = CreateTaskState(
            startsAt: Self.initialStartTime(
                selectedDay: selectedDay,
                timeZone: timeZone
            )
        )
    }

    func loadCreationData() async {
        guard !didLoadZones else { return }
        didLoadZones = true
        state.isLoadingZones = true
        defer { state.isLoadingZones = false }

        do {
            state.zones = try await useCases.fetchZones.execute(for: selectedDay)
            if state.selectedCategoryID == nil {
                state.selectedCategoryID = state.categories.first?.id
            }
        } catch is CancellationError {
            didLoadZones = false
        } catch {
            state.errorMessage = error.localizedDescription
        }

        do {
            let profile = try await useCases.userProfile.execute()
            state.durationMinutes = min(
                480,
                max(15, profile.preferences.preferredSessionDuration)
            )
        } catch is CancellationError {
            didLoadZones = false
        } catch {
            if state.errorMessage == nil {
                state.errorMessage = error.localizedDescription
            }
        }
    }

    func submitCurrentTask() async {
        let title = state.quickText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        if state.isAwanSchedulingEnabled {
            await generateAITask(prompt: title)
        } else {
            await createTask(
                title: title,
                description: nil,
                durationMinutes: state.durationMinutes,
                categoryID: state.selectedCategoryID,
                isSplittable: false,
                mandatory: true,
                startsAt: state.startsAt
            )
        }
    }

    func createTask(
        title: String,
        description: String?,
        durationMinutes: Int,
        categoryID: UUID?,
        isSplittable: Bool,
        mandatory: Bool,
        startsAt: Date
    ) async {
        guard !state.isSubmitting else { return }
        state.isSubmitting = true
        state.errorMessage = nil
        defer { state.isSubmitting = false }

        do {
            _ = try await useCases.createTask.execute(
                CreateTaskRequest(
                    title: title,
                    description: description,
                    durationMinutes: durationMinutes,
                    categoryID: categoryID,
                    isSplittable: isSplittable,
                    mandatory: mandatory,
                    estimatedPoints: 10,
                    startsAt: startsAt,
                    selectedDay: selectedDay,
                    timeZone: timeZone
                )
            )
            state.didCreateTask = true
        } catch is CancellationError {
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        state.errorMessage = nil
    }

    func beginRecording() async {
        guard quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !wantsToRecord else {
            return
        }
    func confirmAndAddAITask(item: AITaskSheetItem, finalDurationMinutes: Int) async {
        await createTask(
            title: item.task.title,
            description: item.task.description,
            durationMinutes: finalDurationMinutes,
            categoryID: nil,
            isSplittable: item.task.isSplittable,
            mandatory: item.task.mandatory,
            startsAt: item.startTime
        )
    }

        wantsToRecord = true
        pendingTranscription = ""
        errorMessage = nil
    func dismissAITaskResult() {
        state.phase = .composer

    private func createTaskWithAwan(prompt: String) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        phase = .aiLoading
        defer {
            isSubmitting = false
        }

        do {
            let aiTaskItems = try await useCases.createAITask.execute(
                CreateAITaskRequest(text: prompt)
            )
            pendingAITaskItems = aiTaskItems
            phase = .aiResult(aiTaskItems)
        } catch is CancellationError {
            phase = .composer
        } catch {
            errorMessage = error.localizedDescription
            phase = .composer
        }
    }

    func confirmAndAddAITask(item: AITaskSheetItem, finalDurationMinutes: Int) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let result = try await useCases.createTask.execute(
                CreateTaskRequest(
                    title: item.task.title,
                    description: item.task.description,
                    durationMinutes: finalDurationMinutes,
                    zoneID: item.task.zoneID,
                    isSplittable: item.task.isSplittable,
                    mandatory: item.task.mandatory,
                    estimatedPoints: item.task.estimatedPoints,
                    startsAt: item.startTime,
                    selectedDay: selectedDay,
                    timeZone: timeZone
                )
            )
            activeNudge = result.nudge
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissAITaskResult() {
        pendingAITaskItems = []
        phase = .composer
    }

    func beginRecording() async {
        await startRecording()
    }

    func finishRecording() async {
        await stopRecording()
    }

    func cancelRecording() {
        resetRecording()
    }
}
