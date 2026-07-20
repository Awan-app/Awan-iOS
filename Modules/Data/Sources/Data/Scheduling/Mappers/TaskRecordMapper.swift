import Domain
import Foundation

extension TaskRecord {
    func toDomain() throws -> AwanTask {
        guard let status = TaskStatus(rawValue: statusRaw) else {
            throw SchedulingError.invalidTaskStatus(raw: statusRaw)
        }
        return AwanTask(
            id: id,
            title: title,
            description: description,
            status: status,
            goalID: goalID,
            zoneID: zoneID,
            duration: try TaskDuration(minutes: estimatedDurationMinutes),
            isSplittable: allowTaskSplitting,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs)
        )
    }

    init(domain task: AwanTask) {
        self.init(
            id: task.id,
            title: task.title,
            description: task.description,
            statusRaw: task.status.rawValue,
            goalID: task.goalID,
            zoneID: task.zoneID,
            estimatedDurationMinutes: task.duration.minutes,
            allowTaskSplitting: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: task.dependencyIDs.sorted(),
            order: 0
        )
    }
}
