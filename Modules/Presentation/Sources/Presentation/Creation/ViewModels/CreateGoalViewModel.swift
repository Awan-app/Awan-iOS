import Domain
import Foundation
import Observation

enum CreateGoalPhase: Equatable {
    case starter
    case loading
    case conversation([GoalDecompositionBlock])
    case proposal(narration: [String], goal: GoalProposal)
    case confirming
}

@Observable
@MainActor
public final class CreateGoalViewModel {
    var prompt = ""
    private(set) var phase: CreateGoalPhase = .starter
    private(set) var sessionID: UUID?
    private(set) var isRecording = false
    private(set) var errorMessage: String?

    var requiresFullScreen: Bool {
        if case .proposal = phase {
            return true
        }
        return phase == .confirming
    }

    @ObservationIgnored private let useCases: GoalDecompositionUseCases
    @ObservationIgnored private let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored private var wantsToRecord = false
    @ObservationIgnored private var pendingTranscription = ""
    @ObservationIgnored private var phaseBeforeLoading: CreateGoalPhase = .starter

    public init(
        useCases: GoalDecompositionUseCases,
        speechTranscriber: any SpeechTranscribing
    ) {
        self.useCases = useCases
        self.speechTranscriber = speechTranscriber
    }

    func submitCurrentPrompt() async {
        await send(message: prompt)
    }

    func selectOption(_ option: String) async {
        await send(message: option)
    }

    func confirmProposal() async -> Bool {
        guard let sessionID else { return false }

        let proposalPhase = phase
        phase = .confirming
        errorMessage = nil

        do {
            let goal = try await useCases.confirmProposal.execute(
                sessionID: sessionID
            )
            try await useCases.scheduleGoal.execute(goalID: goal.id)
            return true
        } catch is CancellationError {
            phase = proposalPhase
            return false
        } catch {
            phase = proposalPhase
            errorMessage = error.localizedDescription
            return false
        }
    }

    func beginRecording() async {
        guard prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
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
        let goalText = transcription.isEmpty
            ? pendingTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
            : transcription

        if !goalText.isEmpty {
            prompt = goalText
        }
        pendingTranscription = ""
    }

    func cancelRecording() {
        wantsToRecord = false
        isRecording = false
        pendingTranscription = ""
        speechTranscriber.cancelTranscribing()
    }

    func dismissError() {
        errorMessage = nil
    }

    private func send(message: String) async {
        let cleanMessage = message.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !cleanMessage.isEmpty, phase != .loading, phase != .confirming else {
            return
        }

        cancelRecording()
        prompt = ""
        errorMessage = nil
        phaseBeforeLoading = phase
        phase = .loading

        do {
            let response = try await useCases.sendMessage.execute(
                GoalDecompositionRequest(
                    sessionID: sessionID,
                    message: cleanMessage
                )
            )
            sessionID = response.sessionID
            phase = Self.phase(for: response)
        } catch is CancellationError {
            phase = phaseBeforeLoading
        } catch {
            phase = phaseBeforeLoading
            prompt = cleanMessage
            errorMessage = error.localizedDescription
        }
    }

    private static func phase(
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
}
