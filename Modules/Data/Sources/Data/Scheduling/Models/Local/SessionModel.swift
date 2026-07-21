import Foundation
import SwiftData

@Model
final class SessionModel {
    @Attribute(.unique) var id: UUID
    var taskID: UUID
    var zoneID: UUID?
    var startDate: Date
    var endDate: Date
    var blocking: Bool
    var statusRaw: String

    init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        startDate: Date,
        endDate: Date,
        blocking: Bool,
        statusRaw: String
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.startDate = startDate
        self.endDate = endDate
        self.blocking = blocking
        self.statusRaw = statusRaw
    }
}
