//
//  GoalsUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsUseCases: Sendable {
    public let fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase
    public let fetchGoalTasks: any FetchGoalTasksUseCase
    public let createEmptyGoal: (any CreateEmptyGoalUseCase)?
    public let addTaskToGoal: (any AddTaskToGoalUseCase)?
    public let fetchInboxTasks: (any FetchInboxTasksUseCase)?

    public init(
        fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase,
        fetchGoalTasks: any FetchGoalTasksUseCase,
        createEmptyGoal: (any CreateEmptyGoalUseCase)? = nil,
        addTaskToGoal: (any AddTaskToGoalUseCase)? = nil,
        fetchInboxTasks: (any FetchInboxTasksUseCase)? = nil
    ) {
        self.fetchGoalsWithTasks = fetchGoalsWithTasks
        self.fetchGoalTasks = fetchGoalTasks
        self.createEmptyGoal = createEmptyGoal
        self.addTaskToGoal = addTaskToGoal
        self.fetchInboxTasks = fetchInboxTasks
    }
}

