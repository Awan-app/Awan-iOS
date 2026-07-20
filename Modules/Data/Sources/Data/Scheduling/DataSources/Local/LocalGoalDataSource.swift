import Domain
import Foundation

public protocol LocalGoalDataSource: Sendable {
    func fetchGoals() async throws -> [Goal]
    func fetchGoal(id: UUID) async throws -> Goal?
    func addGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
}
