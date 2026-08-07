//
//  GoalsUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsUseCases: Sendable {
    public let fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase
    public let fetchGoalTasks: (any FetchGoalTasksUseCase)?

    public init(
        fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase,
        fetchGoalTasks: (any FetchGoalTasksUseCase)? = nil
    ) {
        self.fetchGoalsWithTasks = fetchGoalsWithTasks
        self.fetchGoalTasks = fetchGoalTasks
    }
}
