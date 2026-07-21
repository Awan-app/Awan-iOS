import Domain
import Foundation

public struct DefaultGoalRepository: GoalRepository {
    private let localDataSource: any LocalGoalDataSource

    public init(localDataSource: any LocalGoalDataSource) {
        self.localDataSource = localDataSource
    }

    public func fetchGoals() async throws -> [Goal] {
        try await localDataSource.fetchGoals()
    }
    public func addGoal(_ goal: Goal) async throws {
        try await localDataSource.addGoal(goal)
    }
    public func updateGoal(_ goal: Goal) async throws {
        try await localDataSource.updateGoal(goal)
    }
    public func deleteGoal(id: UUID) async throws {
        try await localDataSource.deleteGoal(id: id)
    }
    public func deleteAllGoals() async throws {
        try await localDataSource.deleteAllGoals()
    }
}
