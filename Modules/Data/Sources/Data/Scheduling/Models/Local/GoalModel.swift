import Foundation
import SwiftData

@Model
final class GoalModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String?
    var statusRaw: String
    var deadline: Date
    var createdAt: Date

    init(
        id: UUID,
        title: String,
        goalDescription: String?,
        statusRaw: String,
        deadline: Date,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.goalDescription = goalDescription
        self.statusRaw = statusRaw
        self.deadline = deadline
        self.createdAt = createdAt
    }
}
