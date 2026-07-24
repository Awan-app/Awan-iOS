import Foundation

public struct CreateTaskRequest: Hashable, Sendable {
    public let title: String
    public let description: String?
    public let durationMinutes: Int
    public let zoneID: UUID?
    public let isSplittable: Bool
    public let mandatory: Bool
    public let estimatedPoints: Int
    public let startsAt: Date?
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        title: String,
        description: String? = nil,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        mandatory: Bool = true,
        estimatedPoints: Int = 0,
        startsAt: Date? = nil,
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.title = title
        self.description = description
        self.durationMinutes = durationMinutes
        self.zoneID = zoneID
        self.isSplittable = isSplittable
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.startsAt = startsAt
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct UpdateTaskRequest: Hashable, Sendable {
    public let taskID: UUID
    public let title: String
    public let durationMinutes: Int
    public let zoneID: UUID?
    public let isSplittable: Bool
    public let blocking: Bool
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        taskID: UUID,
        title: String,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        blocking: Bool,
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.taskID = taskID
        self.title = title
        self.durationMinutes = durationMinutes
        self.zoneID = zoneID
        self.isSplittable = isSplittable
        self.blocking = blocking
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct TaskZoneChange: Hashable, Sendable {
    public let previousZoneID: UUID?

    public init(previousZoneID: UUID?) {
        self.previousZoneID = previousZoneID
    }
}
