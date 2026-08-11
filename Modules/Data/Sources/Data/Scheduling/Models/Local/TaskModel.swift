import Foundation
import SwiftData

@Model
final class TaskModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var statusRaw: String
    var completedAt: Date?
    var goalID: UUID?
    // Retained only so existing stores can migrate without losing cached data.
    var zoneID: UUID?
    var categoryID: UUID?
    var categoryName: String?
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
        completedAt: Date? = nil,
        goalID: UUID?,
        zoneID: UUID?,
        categoryID: UUID? = nil,
        categoryName: String? = nil,
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
        self.completedAt = completedAt
        self.goalID = goalID
        self.zoneID = zoneID
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.allowTaskSplitting = allowTaskSplitting
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.dependencyIDs = dependencyIDs
    }
}
