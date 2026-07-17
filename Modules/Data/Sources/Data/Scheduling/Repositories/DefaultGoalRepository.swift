import Domain
import Foundation

public struct DefaultGoalRepository: GoalRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchGoals() async throws -> [Goal] { await store.fetchGoals() }
    public func addGoal(_ goal: Goal) async throws { await store.addGoal(goal) }
    public func updateGoal(_ goal: Goal) async throws { await store.updateGoal(goal) }
    public func deleteGoal(id: UUID) async throws { await store.deleteGoal(id: id) }
    public func deleteAllGoals() async throws { await store.deleteAllGoals() }
}
