import Common
import Domain
import Foundation

extension CreateGoalViewModel {
    func startRecording() async {
        guard state.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !wantsToRecord else {
            return
        }

        wantsToRecord = true
        pendingTranscription = ""
        state.errorMessage = nil

        do {
            try await speechTranscriber.startTranscribing { [weak self] value in
                self?.pendingTranscription = value
            }
            guard wantsToRecord else {
                speechTranscriber.cancelTranscribing()
                return
            }
            state.isRecording = true
        } catch is CancellationError {
        } catch {
            speechTranscriber.cancelTranscribing()
            wantsToRecord = false
            state.isRecording = false
            state.errorMessage = error.localizedDescription
        }
    }

    func stopRecording() async {
        wantsToRecord = false
        guard state.isRecording else { return }

        state.isRecording = false
        let transcription = await speechTranscriber.stopTranscribing()
        let goalText = transcription.isEmpty
            ? pendingTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
            : transcription

        if !goalText.isEmpty {
            state.prompt = goalText
        }
        pendingTranscription = ""
    }

    func resetRecording() {
        wantsToRecord = false
        state.isRecording = false
        pendingTranscription = ""
        speechTranscriber.cancelTranscribing()
    }

    func send(message: String) async {
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanMessage.isEmpty,
              state.phase != .loading,
              !state.isBusy else {
            return
        }

        cancelRecording()
        state.prompt = ""
        state.errorMessage = nil
        phaseBeforeLoading = state.phase
        state.phase = .loading

        do {
            let response = try await useCases.sendMessage.execute(
                GoalDecompositionRequest(
                    sessionID: state.sessionID,
                    message: cleanMessage
                )
            )
            state.sessionID = response.sessionID
            state.phase = Self.phase(for: response)
        } catch is CancellationError {
            state.phase = phaseBeforeLoading
        } catch {
            state.phase = phaseBeforeLoading
            state.prompt = cleanMessage
            state.errorMessage = error.localizedDescription
        }
    }

    static func phase(
        for response: GoalDecompositionResponse
    ) -> CreateGoalPhase {
        let narration = response.blocks.compactMap { block -> String? in
            guard case .text(let text) = block else { return nil }
            return text
        }
        let proposal = response.blocks.compactMap { block -> GoalProposal? in
            guard case .proposal(let proposal) = block else { return nil }
            return proposal
        }.last

        if let proposal {
            return .proposal(narration: narration, goal: proposal)
        }
        return .conversation(response.blocks)
    }

    func requestSchedule(for goal: ConfirmedGoal) async {
        state.phase = .requestingSchedule
        state.errorMessage = nil

        do {
            let proposal = try await useCases.requestSchedule.execute(goalID: goal.id)
            state.scheduleTasks = GoalScheduleReviewMapper.tasks(
                proposal: proposal,
                confirmedGoal: goal
            )
            state.phase = .scheduleReview
            await loadZoneNames()
        } catch is CancellationError {
            state.phase = .scheduleFailure(L10n.Common.pleaseTryAgain)
        } catch {
            state.phase = .scheduleFailure(error.localizedDescription)
        }
    }

    func confirmSchedule() async -> Bool {
        guard let confirmedGoal = state.confirmedGoal else { return false }
        let items = state.scheduleTasks
            .flatMap(\.sessions)
            .filter(\.isIncluded)
            .map {
                GoalScheduleConfirmationItem(
                    taskID: $0.taskID,
                    zoneID: $0.zoneID,
                    start: $0.start,
                    end: $0.end
                )
            }
        guard !items.isEmpty else { return true }

        state.phase = .confirmingSchedule
        state.errorMessage = nil
        do {
            _ = try await useCases.confirmSchedule.execute(
                goalID: confirmedGoal.id,
                sessions: items
            )
            return true
        } catch is CancellationError {
            state.phase = .scheduleReview
            return false
        } catch {
            state.phase = .scheduleReview
            state.errorMessage = error.localizedDescription
            return false
        }
    }

    func mutateSession(
        id: UUID,
        mutation: (inout GoalScheduleReviewSession) -> Void
    ) {
        for taskIndex in state.scheduleTasks.indices {
            guard let sessionIndex = state.scheduleTasks[taskIndex].sessions
                .firstIndex(where: { $0.id == id }) else {
                continue
            }
            mutation(&state.scheduleTasks[taskIndex].sessions[sessionIndex])
            return
        }
    }

    func loadZoneNames() async {
        let days = Set(
            state.scheduleTasks
                .flatMap(\.sessions)
                .map { Calendar.current.startOfDay(for: $0.start) }
        )
        for day in days {
            guard let zones = try? await useCases.fetchZones.execute(for: day) else {
                continue
            }
            for zone in zones {
                state.zoneNames[zone.id] = zone.name
            }
        }
    }
}
