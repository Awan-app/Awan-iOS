import Domain
import Foundation

extension CreateTaskViewModel {

    func startRecording() async {
        guard state.quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !wantsToRecord else {
            return
        }

        wantsToRecord = true
        pendingTranscription = ""
        state.errorMessage = nil

        do {
            try await speechTranscriber.startTranscribing { [weak self] transcription in
                self?.pendingTranscription = transcription
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
        let taskText = transcription.isEmpty
            ? pendingTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
            : transcription
        if !taskText.isEmpty {
            state.quickText = taskText
        }
        pendingTranscription = ""
    }

    func resetRecording() {
        wantsToRecord = false
        state.isRecording = false
        pendingTranscription = ""
        speechTranscriber.cancelTranscribing()
    }

    static func initialStartTime(
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
