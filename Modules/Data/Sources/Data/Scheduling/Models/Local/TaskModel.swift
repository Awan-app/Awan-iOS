import Foundation
import SwiftData

@Model
final class TaskModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var statusRaw: String
    var goalID: UUID?
    var zoneID: UUID?
    var estimatedDurationMinutes: Int
    var allowTaskSplitting: Bool
    var mandatory: Bool
    var estimatedPoints: Int
    var dependencyIDs: [UUID]

    init(
        id: UUID,
        title: String,
        taskDescription: String?,
        statusRaw: String,
        goalID: UUID?,
        zoneID: UUID?,
        estimatedDurationMinutes: Int,
        allowTaskSplitting: Bool,
        mandatory: Bool,
        estimatedPoints: Int,
        dependencyIDs: [UUID]
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.statusRaw = statusRaw
        self.goalID = goalID
        self.zoneID = zoneID
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.allowTaskSplitting = allowTaskSplitting
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.dependencyIDs = dependencyIDs
    }
}
