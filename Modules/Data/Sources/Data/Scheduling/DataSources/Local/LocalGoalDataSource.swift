import Combine
import Domain
import Foundation

public protocol LocalGoalDataSource: Sendable {
    func fetchGoals() async throws -> [Goal]
    func observeGoals() -> AnyPublisher<[Goal], Error>
    func fetchGoal(id: UUID) async throws -> Goal?
    func replaceActiveGoals(_ goals: [Goal]) async throws
    func addGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
}

public extension LocalGoalDataSource {
    func observeGoals() -> AnyPublisher<[Goal], Error> {
        AsyncValuePublisher.make { try await fetchGoals() }
    }

    func replaceActiveGoals(_ goals: [Goal]) async throws {
        let activeGoals = try await fetchGoals().filter { $0.status == .active }
        for goal in activeGoals {
            try await deleteGoal(id: goal.id)
        }
        for goal in goals {
            try await addGoal(goal)
        }
    }
}
