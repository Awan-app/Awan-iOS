import Domain

extension GoalRecord {
    func toDomain() throws -> Goal {
        return Goal(
            id: id,
            name: title,
            description: description,
            status: status,
            deadline: deadline,
            createdAt: createdAt
        )
    }

    init(domain goal: Goal) {
        self.init(
            id: goal.id,
            title: goal.name,
            description: goal.description,
            status: goal.status,
            deadline: goal.deadline,
            createdAt: goal.createdAt
        )
    }
}
