//
//  GoalsAction.swift
//  Presentation
//

import Foundation
import Domain

public enum GoalsAction: Sendable {
    case appeared
    case refresh
    case searchQueryChanged(String)
    case selectGoal(UUID)
    case loadGoalTasks(UUID)
    case createGoal(title: String, description: String?, targetDate: Date?)
    case showCreateGoalSheet
    case dismissCreateGoalSheet
    case dismissError
    case showAddTaskSheet(goalID: UUID)
    case dismissAddTaskSheet
    case addInboxTaskToGoal(task: AwanTask, goalID: UUID)
    case dismissAddTaskError
    case showEditGoalSheet(goalID: UUID)
    case dismissEditGoalSheet
    case updateGoal(goalID: UUID, title: String, description: String?, targetDate: Date?)
    case deleteGoal(goalID: UUID)
    case dismissGoalActionError
    case requestAISchedule(goalID: UUID)
    case confirmAISchedule(goalID: UUID)
    case dismissAIScheduleReview
    case toggleScheduleSuggestion(sessionID: UUID)
    case updateScheduleSession(sessionID: UUID, start: Date, end: Date)
    case addManualScheduleSession(taskID: UUID, start: Date, end: Date)
    case removeManualScheduleSession(sessionID: UUID)
    case prepareScheduleConfirmation(goalID: UUID)
    case continueWithoutUnscheduledTasks(goalID: UUID)
    case acceptAllSuggestionsAndConfirm(goalID: UUID)
    case focusFirstUnscheduledTask
    case dismissUnscheduledDialog
    case clearFocusedUnscheduledTask
    case dismissScheduleErrorMessage
    case completeTask(UUID)
}

