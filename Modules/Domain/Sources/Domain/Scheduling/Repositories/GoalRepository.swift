import Combine
import Foundation

public protocol GoalRepository: Sendable {
    func fetchGoals() async throws -> [Goal]
    func observeGoals() -> AnyPublisher<[Goal], Error>
    func fetchGoalTasks(goalID: UUID) async throws -> [AwanTask]
    func addGoal(_ goal: Goal) async throws
    func createGoal(title: String, description: String?, targetDate: Date?) async throws -> Goal
    func addTaskToGoal(goalID: UUID, task: AwanTask) async throws
    func updateGoal(_ goal: Goal) async throws
    func deleteGoal(id: UUID) async throws
    func deleteAllGoals() async throws
}

public extension GoalRepository {
    func observeGoals() -> AnyPublisher<[Goal], Error> {
        AsyncValuePublisher.make { try await fetchGoals() }
    }

    func fetchGoalTasks(goalID: UUID) async throws -> [AwanTask] {
        []
    }

    func createGoal(title: String, description: String?, targetDate: Date?) async throws -> Goal {
        let goal = Goal(id: UUID(), name: title, description: description, status: .active, deadline: targetDate)
        try await addGoal(goal)
        return goal
    }

    func addTaskToGoal(goalID: UUID, task: AwanTask) async throws {}
}

