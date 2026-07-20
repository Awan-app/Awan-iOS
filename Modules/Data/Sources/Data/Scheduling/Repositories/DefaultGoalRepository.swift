import Domain
import Foundation

public struct DefaultGoalRepository: GoalRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchGoals() async throws -> [Goal] {
        try await store.fetchGoals().map { try $0.toDomain() }
    }
    public func addGoal(_ goal: Goal) async throws {
        try await store.addGoal(GoalRecord(domain: goal))
    }
    public func updateGoal(_ goal: Goal) async throws {
        try await store.updateGoal(GoalRecord(domain: goal))
    }
    public func deleteGoal(id: UUID) async throws {
        try await store.deleteGoal(id: id)
    }
    public func deleteAllGoals() async throws {
        try await store.deleteAllGoals()
    }
}
