//
//  AddTaskIntent.swift
//  Awan
//
//  Created by Manona on 25/07/2026.
//

import AppIntents
import AwaNetwork
import Domain
import Foundation

public struct AddTaskIntent: AppIntent {
    public static var title: LocalizedStringResource = "Add a Task"
    public static var description = IntentDescription("Creates a new task in Awan.")

    // TODO: Uncomment when UX is finalised — opens Awan automatically after success.
    // public static var openAppWhenRun: Bool = true

    @Parameter(
        title: LocalizedStringResource("Task Title", comment: "The name of the task"),
        requestValueDialog: IntentDialog(
            LocalizedStringResource("What would you like to call the task?",
                                   comment: "Siri prompt: asking for task title")
        )
    )
    public var title: String

    @Parameter(
        title: LocalizedStringResource("Duration (minutes)", comment: "Estimated task duration in minutes"),
        requestValueDialog: IntentDialog(
            LocalizedStringResource("How many minutes will it take?",
                                   comment: "Siri prompt: asking for task duration")
        )
    )
    public var durationMinutes: Int

    @Parameter(
        title: LocalizedStringResource("Date and Time", comment: "When the task starts"),
        requestValueDialog: IntentDialog(
            LocalizedStringResource("Which day and time should I schedule it for?",
                                   comment: "Siri prompt: asking for task date and time")
        )
    )
    public var scheduledDate: Date

    @Parameter(
        title: LocalizedStringResource("Description", comment: "Optional task description")
    )
    public var taskDescription: String?

    public static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$durationMinutes
            \.$scheduledDate
            \.$taskDescription
        }
    }

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // Guard: user must be signed in before hitting the network.
        guard AuthSessionStore.session != nil else {
            return .result(
                dialog: IntentDialog(
                    LocalizedStringResource(
                        "You need to be signed in to Awan to add a task. Please open the app and log in first.",
                        comment: "Siri error: user not authenticated"
                    )
                )
            )
        }

        let useCase = AppDependencyContainer.shared.resolve(CreateTaskUseCase.self)

        let request = CreateTaskRequest(
            title: title,
            description: taskDescription,
            durationMinutes: durationMinutes,
            zoneID: nil,
            isSplittable: true,
            mandatory: true,
            estimatedPoints: 0,
            startsAt: scheduledDate,
            selectedDay: scheduledDate,
            timeZone: .current
        )

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = .current
        let formattedDate = formatter.string(from: scheduledDate)

        do {
            _ = try await useCase.execute(request)
            return .result(
                dialog: IntentDialog(
                    LocalizedStringResource(
                        "Done! '\(title)' was added to your Awan schedule for \(formattedDate).",
                        comment: "Siri success message after task is created, includes date"
                    )
                )
            )
        } catch {
            let message = friendlyErrorMessage(for: error)
            return .result(dialog: IntentDialog(stringLiteral: message))
        }
    }

    // MARK: - Helpers

    private func friendlyErrorMessage(for error: any Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(let statusCode, _) where statusCode == 401:
                return "Your session has expired. Please open Awan and log in again, then try adding the task."
            case .httpError(_, let apiError):
                let detail = apiError?.message ?? "Please try again."
                return "Awan couldn't save the task. \(detail)"
            case .invalidURL:
                return "Something went wrong with the request. Please try again."
            default:
                return "Couldn't connect to Awan. Please check your internet connection and try again."
            }
        }
        return "Something went wrong. Please open Awan and add the task manually."
    }
}
