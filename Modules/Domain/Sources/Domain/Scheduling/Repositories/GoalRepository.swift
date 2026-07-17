import Foundation

public protocol GoalRepository: Sendable {
    func fetchGoals() async throws -> [Goal]
    func addGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
}
