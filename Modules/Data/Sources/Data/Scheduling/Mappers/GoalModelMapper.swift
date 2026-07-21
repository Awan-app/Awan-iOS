import Domain

extension GoalModel {
    func toDomain() throws -> Goal {
        guard let status = GoalStatus(rawValue: statusRaw) else {
            throw SchedulingError.invalidGoalStatus(raw: statusRaw)
        }
        return Goal(
            id: id,
            name: title,
            description: goalDescription,
            status: status,
            deadline: deadline,
            createdAt: createdAt
        )
    }

    convenience init(domain goal: Goal) {
        self.init(
            id: goal.id,
            title: goal.name,
            goalDescription: goal.description,
            statusRaw: goal.status.rawValue,
            deadline: goal.deadline,
            createdAt: goal.createdAt
        )
    }

    func update(from goal: Goal) {
        title = goal.name
        goalDescription = goal.description
        statusRaw = goal.status.rawValue
        deadline = goal.deadline
        createdAt = goal.createdAt
    }
}
