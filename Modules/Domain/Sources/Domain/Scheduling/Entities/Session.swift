import Foundation

public struct Session: Identifiable, Hashable, Sendable {
    public enum Status: Hashable, Sendable {
        case planned
        case completed
        case missed
        case cancelled
    }

    public let id: UUID
    public let taskID: UUID
    public let zoneID: UUID?
    public let timeRange: TimeRange
    public let blocking: Bool
    public let status: Status
    public let firstCompletedAt: Date?
    
    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        timeRange: TimeRange,
        blocking: Bool,
        status: Status,
        firstCompletedAt: Date? = nil
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.timeRange = timeRange
        self.blocking = blocking
        self.status = status
        self.firstCompletedAt = firstCompletedAt
    }

    public var contributesScheduledWork: Bool {
        status == .planned || status == .completed
    }

    public var occupiesTime: Bool {
        status != .missed && status != .cancelled
    }
}
