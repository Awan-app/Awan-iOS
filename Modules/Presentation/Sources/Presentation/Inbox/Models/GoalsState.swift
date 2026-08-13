//
//  GoalsState.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsState: Equatable, Sendable {
    public var isLoading: Bool
    public var searchQuery: String
    public var allGoals: [GoalProgressItem]
    public var failureMessage: String?
    public var selectedGoalTasks: [AwanTask]
    public var orderedGoalTasks: [GoalDetailTaskItem]
    public var isLoadingGoalTasks: Bool
    public var goalTasksFailureMessage: String?
    public var isCreatingGoal: Bool
    public var isCreateGoalSheetPresented: Bool
    public var addTaskSheetGoalID: UUID?
    public var inboxTasksForSheet: [AwanTask]
    public var isLoadingInboxTasks: Bool
    public var addTaskFailureMessage: String?

    public init(
        isLoading: Bool = false,
        searchQuery: String = "",
        allGoals: [GoalProgressItem] = [],
        failureMessage: String? = nil,
        selectedGoalTasks: [AwanTask] = [],
        orderedGoalTasks: [GoalDetailTaskItem] = [],
        isLoadingGoalTasks: Bool = false,
        goalTasksFailureMessage: String? = nil,
        isCreatingGoal: Bool = false,
        isCreateGoalSheetPresented: Bool = false,
        addTaskSheetGoalID: UUID? = nil,
        inboxTasksForSheet: [AwanTask] = [],
        isLoadingInboxTasks: Bool = false,
        addTaskFailureMessage: String? = nil
    ) {
        self.isLoading = isLoading
        self.searchQuery = searchQuery
        self.allGoals = allGoals
        self.failureMessage = failureMessage
        self.selectedGoalTasks = selectedGoalTasks
        self.orderedGoalTasks = orderedGoalTasks
        self.isLoadingGoalTasks = isLoadingGoalTasks
        self.goalTasksFailureMessage = goalTasksFailureMessage
        self.isCreatingGoal = isCreatingGoal
        self.isCreateGoalSheetPresented = isCreateGoalSheetPresented
        self.addTaskSheetGoalID = addTaskSheetGoalID
        self.inboxTasksForSheet = inboxTasksForSheet
        self.isLoadingInboxTasks = isLoadingInboxTasks
        self.addTaskFailureMessage = addTaskFailureMessage
    }


    public var filteredGoals: [GoalProgressItem] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allGoals }
        return allGoals.filter { goal in
            goal.title.localizedCaseInsensitiveContains(query)
            || (goal.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}
