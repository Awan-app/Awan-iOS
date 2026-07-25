import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class CreateTaskViewModel {
    public private(set) var zones: [Zone] = []
    public private(set) var isLoadingZones = false
    public private(set) var isSubmitting = false
    public private(set) var errorMessage: String?
    public private(set) var didCreateTask = false
    public private(set) var activeNudge: ScheduleNudge?
    /// Drives `GoalCreationLoadingView` sheet presentation.
    private(set) var isShowingAILoading = false
    /// Drives `AITaskResultSheet` presentation once the AI call completes.
    private(set) var pendingAITaskItem: AITaskSheetItem?
    var quickText = ""
    var isAwanSchedulingEnabled = true
    var durationMinutes = 60
    var startsAt: Date
    var selectedZoneID: UUID?
    private(set) var isRecording = false

    let selectedDay: Date

    @ObservationIgnored private let useCases: CreationUseCases
    @ObservationIgnored private let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored private let timeZone: TimeZone
    @ObservationIgnored private var didLoadZones = false
    @ObservationIgnored private var wantsToRecord = false
    @ObservationIgnored private var pendingTranscription = ""

    public init(
        useCases: CreationUseCases,
        speechTranscriber: any SpeechTranscribing,
        selectedDay: Date = Date(),
        timeZone: TimeZone = .current
    ) {
        self.useCases = useCases
        self.speechTranscriber = speechTranscriber
        self.selectedDay = selectedDay
        self.timeZone = timeZone
        self.startsAt = Self.initialStartTime(
            selectedDay: selectedDay,
            timeZone: timeZone
        )
    }

    func loadCreationData() async {
        guard !didLoadZones else { return }
        didLoadZones = true
        isLoadingZones = true
        defer { isLoadingZones = false }

        do {
            zones = try await useCases.fetchZones.execute(for: selectedDay)
            if selectedZoneID == nil {
                selectedZoneID = zones.first?.id
            }
        } catch is CancellationError {
            didLoadZones = false
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let profile = try await useCases.userProfile.execute()
            durationMinutes = min(
                480,
                max(15, profile.preferences.preferredSessionDuration)
            )
        } catch is CancellationError {
            didLoadZones = false
        } catch {
            if errorMessage == nil {
                errorMessage = error.localizedDescription
            }
        }
    }

    func loadZones() async {
        await loadCreationData()
    }

    func submitCurrentTask() async {
        let title = quickText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        if isAwanSchedulingEnabled {
            await createTaskWithAwan(prompt: title)
        } else {
            await createTask(
                title: title,
                description: nil,
                durationMinutes: durationMinutes,
                zoneID: selectedZoneID,
                isSplittable: false,
                mandatory: true,
                startsAt: startsAt
            )
        }
    }

    func createTask(
        title: String,
        description: String?,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        mandatory: Bool,
        startsAt: Date
    ) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let result = try await useCases.createTask.execute(
                CreateTaskRequest(
                    title: title,
                    description: description,
                    durationMinutes: durationMinutes,
                    zoneID: zoneID,
                    isSplittable: isSplittable,
                    mandatory: mandatory,
                    estimatedPoints: 10,
                    startsAt: startsAt,
                    selectedDay: selectedDay,
                    timeZone: timeZone
                )
            )
            activeNudge = result.nudge
            didCreateTask = true
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func createTaskWithAwan(prompt: String) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        isShowingAILoading = true
        defer {
            isSubmitting = false
            isShowingAILoading = false
        }

        let startTime = Date()

        do {
            let aiTask = try await useCases.createAITask.execute(
                CreateAITaskRequest(title: prompt)
            )
            pendingAITaskItem = AITaskSheetItem(task: aiTask, startTime: startTime)
        } catch is CancellationError {
            // User cancelled — abort silently.
        } catch {
            // TODO: Remove once backend is stable. Fall back to mock data so the
            // UI flow is always testable end-to-end during development.
            #if DEBUG
            print("[CreateTaskViewModel] AI endpoint failed (\(error)). Using mock data.")
            #endif
            pendingAITaskItem = AITaskSheetItem(
                task: AITask(
                    id: UUID(),
                    title: prompt,
                    description: nil,
                    estimatedDuration: 60,
                    status: "SCHEDULED",
                    mandatory: true,
                    estimatedPoints: 20,
                    isSplittable: false,
                    goalID: UUID(),
                    dependencyIDs: [],
                    category: TaskCategory(id: UUID(), name: "General")
                ),
                startTime: startTime
            )
        }
    }

    func dismissAITaskResult() {
        pendingAITaskItem = nil
    }

    func beginRecording() async {
        guard quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !wantsToRecord else {
            return
        }

        wantsToRecord = true
        pendingTranscription = ""
        errorMessage = nil

        do {
            try await speechTranscriber.startTranscribing { [weak self] transcription in
                self?.pendingTranscription = transcription
            }
            guard wantsToRecord else {
                speechTranscriber.cancelTranscribing()
                return
            }
            isRecording = true
        } catch is CancellationError {
        } catch {
            speechTranscriber.cancelTranscribing()
            wantsToRecord = false
            isRecording = false
            errorMessage = error.localizedDescription
        }
    }

    func finishRecording() async {
        wantsToRecord = false
        guard isRecording else { return }

        isRecording = false
        let transcription = await speechTranscriber.stopTranscribing()
        let taskText = transcription.isEmpty
            ? pendingTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
            : transcription
        #if DEBUG
        print("Speech transcription result: \(taskText)")
        #endif
        if !taskText.isEmpty {
            quickText = taskText
        }
        pendingTranscription = ""
    }

    func cancelRecording() {
        wantsToRecord = false
        isRecording = false
        pendingTranscription = ""
        speechTranscriber.cancelTranscribing()
    }

    private static func initialStartTime(
        selectedDay: Date,
        timeZone: TimeZone
    ) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let now = Date()
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: now
        )
        return calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: 0,
            of: selectedDay
        ) ?? selectedDay
    }
}
