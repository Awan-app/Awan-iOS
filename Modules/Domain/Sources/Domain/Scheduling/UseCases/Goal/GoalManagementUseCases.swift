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
    func execute(goalID: UUID, task: AwanTask) async throws -> AwanTask
}

public struct DefaultAddTaskToGoalUseCase: AddTaskToGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(goalID: UUID, task: AwanTask) async throws -> AwanTask {
        try await repository.addTaskToGoal(goalID: goalID, task: task)
    }
}

public protocol UpdateGoalUseCase: Sendable {
    func execute(id: UUID, title: String, description: String?, targetDate: Date?) async throws -> Goal
}

public struct DefaultUpdateGoalUseCase: UpdateGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, title: String, description: String?, targetDate: Date?) async throws -> Goal {
        let updated = Goal(
            id: id,
            name: title,
            description: description,
            deadline: targetDate
        )
        try await repository.updateGoal(updated)
        return updated
    }
}

public protocol DeleteGoalUseCase: Sendable {
    func execute(id: UUID) async throws
}

public struct DefaultDeleteGoalUseCase: DeleteGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteGoal(id: id)
    }
}
