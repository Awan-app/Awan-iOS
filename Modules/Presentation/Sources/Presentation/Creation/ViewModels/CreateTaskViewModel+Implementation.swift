import Domain
import Common
import Foundation

extension CreateTaskViewModel {
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

    private func showAIResult(task: AwanTask, startTime: Date) {
        state.phase = .aiResult(AITaskSheetItem(task: task, startTime: startTime))
    }

    func uploadImageForTasks(imageData: Data, mimeType: ImageType, note: String?) async {
        guard !state.isSubmitting else { return }
        state.isSubmitting = true
        state.errorMessage = nil
        state.phase = .imageUploading(L10n.Home.imageUploading)
        defer { state.isSubmitting = false }

        do {
            let response = try await useCases.imageToTasks.execute(
                imageData: imageData,
                mimeType: mimeType.rawValue,
                note: note
            )
            state.phase = .imageTasksResult(response)
        } catch is CancellationError {
            state.phase = .composer
        } catch {
            state.phase = .composer
            state.errorMessage = error.localizedDescription
        }
    }

    func acceptProposedTasks(_ tasks: [ProposedTask]) async {
        guard !state.isSubmitting, !tasks.isEmpty else { return }
        state.isSubmitting = true
        state.errorMessage = nil
        defer { state.isSubmitting = false }

        do {
            for task in tasks {
                var draft = task.draft
                if draft.sessions.isEmpty {
                    draft.sessions = task.aiProposedSessions
                }
                _ = try await useCases.acceptProposedTask.execute(draft)
            }
            state.didCreateTask = true
        } catch is CancellationError {
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
}
