import Common
import _PhotosUI_SwiftUI
import Domain
import Foundation
import Observation
import PhotosUI

@Observable
@MainActor
final class CreateTaskViewModel {
    var state: CreateTaskState
    var activeNudge: ScheduleNudge?

    let selectedDay: Date

    @ObservationIgnored let useCases: CreationUseCases
    @ObservationIgnored let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored let timeZone: TimeZone
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
        await startRecording()
    }

    func finishRecording() async {
        await stopRecording()
    }

    func cancelRecording() {
        resetRecording()
    }

    func processPickedPhoto(_ item: PhotosPickerItem, note: String?) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        let mimeType = ImageType.from(item.supportedContentTypes.first)
        await uploadImageForTasks(imageData: data, mimeType: mimeType, note: note)
    }

    func processCapturedImage(_ data: Data, note: String?) async {
        await uploadImageForTasks(imageData: data, mimeType: .jpeg, note: note)
    }

    func processUploadedImage(imageData: Data, mimeType: ImageType, note: String?) async {
        await uploadImageForTasks(imageData: imageData, mimeType: mimeType, note: note)
    }

    func confirmAndAcceptProposedTasks(_ selectedTasks: [ProposedTask]) async {
        await acceptProposedTasks(selectedTasks, destination: .schedule)
    }

    func confirmAndAddProposedTasksToInbox(_ selectedTasks: [ProposedTask]) async {
        await acceptProposedTasks(selectedTasks, destination: .inbox)
    }
}
