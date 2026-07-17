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

    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        timeRange: TimeRange,
        blocking: Bool,
        status: Status
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.timeRange = timeRange
        self.blocking = blocking
        self.status = status
    }

    public var contributesScheduledWork: Bool {
        status == .planned || status == .completed
    }

    public var occupiesTime: Bool {
        status != .missed && status != .cancelled
    }
}
