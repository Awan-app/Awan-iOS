import Domain

extension TaskModel {
    func toDomain() throws -> AwanTask {
        let status: TaskStatus
        switch statusRaw {
        case "pending", "inProgress":
            status = .active
        default:
            guard let currentStatus = TaskStatus(rawValue: statusRaw) else {
                throw SchedulingError.invalidTaskStatus(raw: statusRaw)
            }
            status = currentStatus
        }
        return try AwanTask(
            id: id,
            title: title,
            description: taskDescription,
            status: status,
            completedAt: completedAt,
            goalID: goalID,
            duration: TaskDuration(minutes: estimatedDurationMinutes),
            isSplittable: allowTaskSplitting,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs),
            category: categoryID.flatMap { id in
                categoryName.map { TaskCategory(id: id, name: $0) }
            }
        )
    }

    convenience init(domain task: AwanTask) {
        self.init(
            id: task.id,
            title: task.title,
            taskDescription: task.description,
            statusRaw: task.status.rawValue,
            completedAt: task.completedAt,
            goalID: task.goalID,
            zoneID: nil,
            categoryID: task.category?.id,
            categoryName: task.category?.name,
            estimatedDurationMinutes: task.duration.minutes,
            allowTaskSplitting: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: task.dependencyIDs.sorted()
        )
    }

    func update(from task: AwanTask) {
        title = task.title
        taskDescription = task.description
        statusRaw = task.status.rawValue
        completedAt = task.completedAt
        goalID = task.goalID
        categoryID = task.category?.id
        categoryName = task.category?.name
        estimatedDurationMinutes = task.duration.minutes
        allowTaskSplitting = task.isSplittable
        mandatory = task.mandatory
        estimatedPoints = task.estimatedPoints
        dependencyIDs = task.dependencyIDs.sorted()
    }
}
