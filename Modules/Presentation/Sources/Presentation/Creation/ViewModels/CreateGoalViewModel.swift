import Foundation
import Observation

@Observable
@MainActor
public final class CreateGoalViewModel {
    var prompt = ""
    public private(set) var submittedPrompt: String?
    public private(set) var isRecording = false
    public private(set) var errorMessage: String?

    @ObservationIgnored private let speechTranscriber: any SpeechTranscribing
    @ObservationIgnored private var wantsToRecord = false
    @ObservationIgnored private var pendingTranscription = ""

    public init(speechTranscriber: any SpeechTranscribing) {
        self.speechTranscriber = speechTranscriber
    }

    func submitCurrentPrompt() {
        let cleanPrompt = prompt.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !cleanPrompt.isEmpty else { return }

        errorMessage = nil
        submittedPrompt = cleanPrompt
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
}
