import Domain
import Foundation

public protocol LocalGoalDataSource: Sendable {
    func fetchGoals() async throws -> [GoalRecord]
    func fetchGoal(id: UUID) async throws -> Goal?
    func fetchInboxTasks() async throws -> [AwanTask]
    func fetchTasks(goalID: UUID) async throws -> [AwanTask]
    func addGoal(_ goal: GoalRecord) async throws
    func updateGoal(_ goal: GoalRecord) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
    func addTasks(_ tasks: [AwanTask]) async throws
}
