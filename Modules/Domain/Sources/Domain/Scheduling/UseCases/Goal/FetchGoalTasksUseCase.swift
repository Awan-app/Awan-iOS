//
//  FetchGoalTasksUseCase.swift
//  Domain
//

import Foundation

public protocol FetchGoalTasksUseCase: Sendable {
    func execute(goalID: UUID) async throws -> [AwanTask]
}

public struct DefaultFetchGoalTasksUseCase: FetchGoalTasksUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute(goalID: UUID) async throws -> [AwanTask] {
        try await repository.fetchGoalTasks(goalID: goalID)
    }
}
