import Foundation

@MainActor
public protocol SpeechTranscribing: AnyObject {
    func startTranscribing(
        onUpdate: @escaping (String) -> Void
    ) async throws
    func stopTranscribing() async -> String
    func cancelTranscribing()
}

public enum SpeechTranscriptionError: LocalizedError {
    case microphonePermissionDenied
    case speechRecognitionPermissionDenied
    case speechRecognizerUnavailable
    case audioInputUnavailable

    public var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            "Microphone access is required to record a task."
        case .speechRecognitionPermissionDenied:
            "Speech recognition access is required to transcribe a task."
        case .speechRecognizerUnavailable:
            "Speech recognition is currently unavailable."
        case .audioInputUnavailable:
            "No valid microphone input is currently available."
        }
    }
}

#if os(iOS)
import AVFAudio
import Speech

@MainActor
public final class LiveSpeechTranscriber: SpeechTranscribing {
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var stopContinuation: CheckedContinuation<String, Never>?
    private var stopTimeoutTask: Task<Void, Never>?
    private var latestTranscription = ""
    private var transcriptionUpdateHandler: ((String) -> Void)?
    private var hasInstalledTap = false

    public init(locale: Locale = .current) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    public func startTranscribing(
        onUpdate: @escaping (String) -> Void
    ) async throws {
        cancelTranscribing()

        guard await Self.requestSpeechAuthorization() else {
            throw SpeechTranscriptionError.speechRecognitionPermissionDenied
        }
        guard await Self.requestMicrophoneAuthorization() else {
            throw SpeechTranscriptionError.microphonePermissionDenied
        }
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechTranscriptionError.speechRecognizerUnavailable
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            guard recordingFormat.sampleRate > 0,
                  recordingFormat.channelCount > 0 else {
                throw SpeechTranscriptionError.audioInputUnavailable
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.taskHint = .dictation
            request.requiresOnDeviceRecognition = false
            recognitionRequest = request
            latestTranscription = ""
            transcriptionUpdateHandler = onUpdate

            recognitionTask = speechRecognizer.recognitionTask(
                with: request,
                resultHandler: Self.makeRecognitionHandler(owner: self)
            )

            inputNode.installTap(
                onBus: 0,
                bufferSize: 1_024,
                format: recordingFormat,
                block: Self.makeAudioTapHandler(request: request)
            )
            hasInstalledTap = true

            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            cancelTranscribing()
            throw error
        }
    }

    public func stopTranscribing() async -> String {
        guard recognitionRequest != nil else {
            return latestTranscription
        }

        stopAudioCapture()
        recognitionRequest?.endAudio()

        return await withCheckedContinuation { continuation in
            stopContinuation = continuation
            stopTimeoutTask?.cancel()
            stopTimeoutTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.finishStopping()
            }
        }
    }

    public func cancelTranscribing() {
        stopAudioCapture()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        finishStopping()
    }

    nonisolated private static func requestSpeechAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return status == .authorized
    }

    nonisolated private static func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { isGranted in
                continuation.resume(returning: isGranted)
            }
        }
    }

    nonisolated private static func makeAudioTapHandler(
        request: SFSpeechAudioBufferRecognitionRequest
    ) -> AVAudioNodeTapBlock {
        { buffer, _ in
            request.append(buffer)
        }
    }

    nonisolated private static func makeRecognitionHandler(
        owner: LiveSpeechTranscriber
    ) -> (SFSpeechRecognitionResult?, (any Error)?) -> Void {
        { [weak owner] result, error in
            let transcription = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal == true
            let didFail = error != nil
            #if DEBUG
            if let error {
                print("Speech recognition error: \(error.localizedDescription)")
            }
            #endif

            Task { @MainActor [weak owner] in
                owner?.handleRecognitionUpdate(
                    transcription: transcription,
                    shouldFinish: isFinal || didFail
                )
            }
        }
    }

    private func handleRecognitionUpdate(
        transcription: String?,
        shouldFinish: Bool
    ) {
        if let transcription {
            latestTranscription = transcription
            transcriptionUpdateHandler?(transcription)
        }
        if shouldFinish {
            finishStopping()
        }
    }

    private func stopAudioCapture() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        if hasInstalledTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }
        audioEngine.reset()
    }

    private func finishStopping() {
        stopTimeoutTask?.cancel()
        stopTimeoutTask = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        transcriptionUpdateHandler = nil

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )

        let transcription = latestTranscription
            .trimmingCharacters(in: .whitespacesAndNewlines)
        stopContinuation?.resume(returning: transcription)
        stopContinuation = nil
    }
}
#else
@MainActor
public final class LiveSpeechTranscriber: SpeechTranscribing {
    public init(locale: Locale = .current) {}

    public func startTranscribing(
        onUpdate: @escaping (String) -> Void
    ) async throws {
        throw SpeechTranscriptionError.speechRecognizerUnavailable
    }

    public func stopTranscribing() async -> String {
        ""
    }

    public func cancelTranscribing() {}
}
#endif
