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

struct AddTaskIntentDependencies: Sendable {
    let createTask: any CreateTaskUseCase
    let fetchCategories: any FetchCategoriesUseCase
}

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

    @Parameter(
        title: LocalizedStringResource("Category", comment: "The task category"),
        requestValueDialog: IntentDialog(
            LocalizedStringResource(
                "Which category should I use?",
                comment: "Siri prompt: asking for task category"
            )
        )
    )
    public var category: TaskCategoryAppEntity

    @AppDependency
    private var dependencies: AddTaskIntentDependencies

    public static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$durationMinutes
            \.$scheduledDate
            \.$taskDescription
            \.$category
        }
    }

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw $title.needsValueError(
                IntentDialog(
                    LocalizedStringResource(
                        "The task title can't be empty. What should I call it?",
                        comment: "Siri validation: task title is empty"
                    )
                )
            )
        }

        guard durationMinutes > 0 else {
            throw $durationMinutes.needsValueError(
                IntentDialog(
                    LocalizedStringResource(
                        "The duration must be greater than zero. How many minutes will it take?",
                        comment: "Siri validation: task duration is invalid"
                    )
                )
            )
        }

        let trimmedDescription = taskDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = trimmedDescription?.isEmpty == false
            ? trimmedDescription
            : nil

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

        let request = CreateTaskRequest(
            title: trimmedTitle,
            description: normalizedDescription,
            durationMinutes: durationMinutes,
            categoryID: category.id,
            isSplittable: false,
            mandatory: true,
            estimatedPoints: 10,
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
            _ = try await dependencies.createTask.execute(request)
            return .result(
                dialog: IntentDialog(
                    LocalizedStringResource(
                        "Done! '\(trimmedTitle)' was added to your Awan schedule for \(formattedDate).",
                        comment: "Siri success message after task is created, includes date"
                    )
                )
            )
        } catch {
            let message = friendlyErrorMessage(for: error)
            return .result(dialog: IntentDialog(message))
        }
    }

    // MARK: - Helpers

    private func friendlyErrorMessage(for error: any Error) -> LocalizedStringResource {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(let statusCode, _) where statusCode == 401:
                return LocalizedStringResource(
                    "Your session has expired. Please open Awan and log in again, then try adding the task."
                )
            case .httpError:
                return LocalizedStringResource(
                    "Awan couldn't save the task. Please try again."
                )
            case .invalidURL:
                return LocalizedStringResource(
                    "Something went wrong with the request. Please try again."
                )
            default:
                return LocalizedStringResource(
                    "Couldn't connect to Awan. Please check your internet connection and try again."
                )
            }
        }
        return LocalizedStringResource(
            "Something went wrong. Please open Awan and add the task manually."
        )
    }
}
