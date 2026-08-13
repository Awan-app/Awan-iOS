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
}

