//
//  GoalManagementUseCases.swift
//  Domain
//

import Foundation

public protocol CreateEmptyGoalUseCase: Sendable {
    func execute(title: String, description: String?, targetDate: Date?) async throws -> Goal
}

public struct DefaultCreateEmptyGoalUseCase: CreateEmptyGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(title: String, description: String?, targetDate: Date?) async throws -> Goal {
        try await repository.createGoal(title: title, description: description, targetDate: targetDate)
    }
}

public protocol AddTaskToGoalUseCase: Sendable {
    func execute(goalID: UUID, task: AwanTask) async throws
}

public struct DefaultAddTaskToGoalUseCase: AddTaskToGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(goalID: UUID, task: AwanTask) async throws {
        try await repository.addTaskToGoal(goalID: goalID, task: task)
    }
}
