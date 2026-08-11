import Common
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class CreateGoalViewModel {
    var state = CreateGoalState()

    @ObservationIgnored let useCases: GoalDecompositionUseCases
    @ObservationIgnored let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored var wantsToRecord = false
    @ObservationIgnored var pendingTranscription = ""
    @ObservationIgnored var phaseBeforeLoading: CreateGoalPhase = .starter

    public init(
        useCases: GoalDecompositionUseCases,
        speechTranscriber: any SpeechTranscribing
    ) {
        self.useCases = useCases
        self.speechTranscriber = speechTranscriber
    }

    func submitCurrentPrompt() async {
        await send(message: state.prompt)
    }

    func selectOption(_ option: String) async {
        await send(message: option)
    }

    func confirmProposal() async {
        guard let sessionID = state.sessionID else { return }

        let proposalPhase = state.phase
        state.phase = .confirmingGoal
        state.errorMessage = nil

        do {
            let goal = try await useCases.confirmProposal.execute(
                sessionID: sessionID
            )
            state.confirmedGoal = goal
            await requestSchedule(for: goal)
        } catch is CancellationError {
            state.phase = proposalPhase
        } catch {
            state.phase = proposalPhase
            state.errorMessage = error.localizedDescription
        }
    }

    func retryScheduling() async {
        guard let confirmedGoal = state.confirmedGoal else { return }
        await requestSchedule(for: confirmedGoal)
    }

    func prepareScheduleConfirmation() async -> Bool {
        if !state.unresolvedTasks.isEmpty {
            state.focusedUnscheduledTaskID = nil
            state.showsUnscheduledDialog = true
            return false
        }
        return await confirmSchedule()
    }

    func continueWithoutUnscheduledTasks() async -> Bool {
        state.showsUnscheduledDialog = false
        return await confirmSchedule()
    }

    func focusFirstUnscheduledTask() {
        state.showsUnscheduledDialog = false
        state.focusedUnscheduledTaskID = state.unresolvedTasks.first?.taskID
    }

    func dismissUnscheduledDialog() {
        state.showsUnscheduledDialog = false
    }

    func clearFocusedUnscheduledTask() {
        state.focusedUnscheduledTaskID = nil
    }

    func toggleSuggestion(sessionID: UUID) {
        mutateSession(id: sessionID) { $0.isAccepted.toggle() }
    }

    func updateSession(sessionID: UUID, start: Date, end: Date) {
        mutateSession(id: sessionID) {
            $0.start = start
            $0.end = end
            $0.isEdited = true
        }
    }

    func addManualSession(taskID: UUID, start: Date, end: Date) {
        guard let taskIndex = state.scheduleTasks.firstIndex(where: {
            $0.taskID == taskID
        }) else { return }

        state.scheduleTasks[taskIndex].sessions.append(
            GoalScheduleReviewSession(
                id: UUID(),
                taskID: taskID,
                zoneID: nil,
                start: start,
                end: end,
                kind: .manual,
                isAccepted: true,
                isEdited: false
            )
        )
    }

    func removeManualSession(sessionID: UUID) {
        for taskIndex in state.scheduleTasks.indices {
            state.scheduleTasks[taskIndex].sessions.removeAll {
                $0.id == sessionID && $0.isManual
            }
        }
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

    func dismissError() {
        state.errorMessage = nil
    }
}
