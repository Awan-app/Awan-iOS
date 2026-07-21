import Domain

extension TaskModel {
    func toDomain() throws -> AwanTask {
        guard let status = TaskStatus(rawValue: statusRaw) else {
            throw SchedulingError.invalidTaskStatus(raw: statusRaw)
        }
        return try AwanTask(
            id: id,
            title: title,
            description: taskDescription,
            status: status,
            goalID: goalID,
            zoneID: zoneID,
            duration: TaskDuration(minutes: estimatedDurationMinutes),
            isSplittable: allowTaskSplitting,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs)
        )
    }

    convenience init(domain task: AwanTask) {
        self.init(
            id: task.id,
            title: task.title,
            taskDescription: task.description,
            statusRaw: task.status.rawValue,
            goalID: task.goalID,
            zoneID: task.zoneID,
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
        goalID = task.goalID
        zoneID = task.zoneID
        estimatedDurationMinutes = task.duration.minutes
        allowTaskSplitting = task.isSplittable
        mandatory = task.mandatory
        estimatedPoints = task.estimatedPoints
        dependencyIDs = task.dependencyIDs.sorted()
    }
}
