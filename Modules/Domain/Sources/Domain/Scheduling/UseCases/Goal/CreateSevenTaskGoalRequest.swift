import Foundation

public struct CreateSevenTaskGoalRequest: Hashable, Sendable {
    public let name: String
    public let zoneID: UUID
    public let taskDurationMinutes: Int
    public let startDay: Date
    public let timeZone: TimeZone

    public init(
        name: String,
        zoneID: UUID,
        taskDurationMinutes: Int,
        startDay: Date,
        timeZone: TimeZone
    ) {
        self.name = name
        self.zoneID = zoneID
        self.taskDurationMinutes = taskDurationMinutes
        self.startDay = startDay
        self.timeZone = timeZone
    }
}
