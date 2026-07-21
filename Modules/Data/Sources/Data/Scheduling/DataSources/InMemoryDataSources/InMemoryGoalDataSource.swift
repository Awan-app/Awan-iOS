import Domain
import Foundation

public actor InMemoryGoalDataSource: LocalGoalDataSource {
    private var goalsByID: [UUID: Goal]

    public init(goals: [Goal] = []) {
        goalsByID = goals.reduce(into: [:]) { $0[$1.id] = $1 }
    }

    public func fetchGoals() -> [Goal] {
        Array(goalsByID.values)
    }

    public func fetchGoal(id: UUID) -> Goal? {
        goalsByID[id]
    }

    public func addGoal(_ goal: Goal) throws {
        guard goalsByID[goal.id] == nil else {
            throw SchedulingPersistenceError.duplicateID(goal.id)
        }
        goalsByID[goal.id] = goal
    }

    public func updateGoal(_ goal: Goal) throws {
        guard goalsByID[goal.id] != nil else {
            throw SchedulingError.entityNotFound(id: goal.id)
        }
        goalsByID[goal.id] = goal
    }

    public func deleteGoal(id: UUID) {
        goalsByID[id] = nil
    }

    public func deleteAllGoals() {
        goalsByID.removeAll()
    }
}
