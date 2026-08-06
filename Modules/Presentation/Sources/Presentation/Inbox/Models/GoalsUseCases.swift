//
//  GoalsUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsUseCases: Sendable {
    public let fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase

    public init(fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase) {
        self.fetchGoalsWithTasks = fetchGoalsWithTasks
    }
}
