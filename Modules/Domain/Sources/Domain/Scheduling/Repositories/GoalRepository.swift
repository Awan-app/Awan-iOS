import Combine
import Foundation

public protocol GoalRepository: Sendable {
    func fetchGoals() async throws -> [Goal]
    func observeGoals() -> AnyPublisher<[Goal], Error>
    func addGoal(_ goal: Goal) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
}

public extension GoalRepository {
    func observeGoals() -> AnyPublisher<[Goal], Error> {
        AsyncValuePublisher.make { try await fetchGoals() }
    }
}
