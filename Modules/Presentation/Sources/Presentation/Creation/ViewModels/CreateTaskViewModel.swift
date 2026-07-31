import Domain
import Foundation
import Observation

@Observable
@MainActor
final class CreateTaskViewModel {
    var state: CreateTaskState
    private(set) var activeNudge: ScheduleNudge?

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
            await createTaskWithAwan(prompt: title)
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

    func createTaskWithAwan(prompt: String) async {
        guard !state.isSubmitting else { return }
        state.startAILoading()

        do {
            let aiTaskItems = try await useCases.createAITask.execute(
                CreateAITaskRequest(text: prompt)
            )
            state.setAIResult(aiTaskItems)
        } catch is CancellationError {
            state.cancelAI()
        } catch {
            state.setAIError(error.localizedDescription)
        }
    }

    func generateAITask(prompt: String) async {
        await createTaskWithAwan(prompt: prompt)
    }

    func confirmAndAddAITask(item: AITaskSheetItem, finalDurationMinutes: Int) async {
        guard !state.isSubmitting else { return }
        state.isSubmitting = true
        state.errorMessage = nil
        defer { state.isSubmitting = false }

        do {
            let result = try await useCases.createTask.execute(
                CreateTaskRequest(
                    title: item.task.title,
                    description: item.task.description,
                    durationMinutes: finalDurationMinutes,
                    categoryID: item.task.category?.id,
                    isSplittable: item.task.isSplittable,
                    mandatory: item.task.mandatory,
                    estimatedPoints: item.task.estimatedPoints,
                    startsAt: item.startTime,
                    selectedDay: selectedDay,
                    timeZone: timeZone
                )
            )
            state.didCreateTask = true
            activeNudge = result.nudge
        } catch is CancellationError {
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }

    func dismissAITaskResult() {
        state.dismissAITaskResult()
    }

    func dismissError() {
        state.errorMessage = nil
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

