import Common
import _PhotosUI_SwiftUI
import Domain
import Foundation
import Observation
import PhotosUI
import Combine

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
    @ObservationIgnored private var categoryCancellable: AnyCancellable?
    @ObservationIgnored private var didResolveInitialCategory = false
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
                selectedDay: Date(),
                timeZone: timeZone
            )
        )
    }

    func loadCreationData() async {
        loadCategories()
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

    func retryCategories() {
        loadCategories()
    }

    private func loadCategories() {
        categoryCancellable?.cancel()
        state.categoryErrorMessage = nil
        categoryCancellable = useCases.fetchCategories.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    self?.state.categoryErrorMessage = error.localizedDescription
                },
                receiveValue: { [weak self] categories in
                    self?.applyCategories(categories)
                }
            )
    }

    private func applyCategories(_ categories: [TaskCategory]) {
        state.categories = categories
        if let selectedID = state.selectedCategoryID,
           categories.contains(where: { $0.id == selectedID }) {
            didResolveInitialCategory = true
            return
        }
        if !didResolveInitialCategory, let first = categories.first {
            state.selectedCategoryID = first.id
            didResolveInitialCategory = true
        } else if state.selectedCategoryID != nil {
            state.selectedCategoryID = categories.first?.id
        }
    }

    func submitCurrentTask() async {
        guard !state.categories.isEmpty else {
            state.categoryErrorMessage = state.categoryErrorMessage ?? L10n.Common.pleaseTryAgain
            state.errorMessage = state.categoryErrorMessage
            return
        }
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
                startsAt: state.isManualSchedulingEnabled
                    ? state.startsAt
                    : nil
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
        startsAt: Date?
    ) async {
        guard !state.categories.isEmpty else {
            state.errorMessage = state.categoryErrorMessage ?? L10n.Common.pleaseTryAgain
            return
        }
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
                    selectedDay: startsAt ?? selectedDay,
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
