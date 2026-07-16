import Foundation

public struct Session: Identifiable, Hashable, Sendable {
    public enum Placement: Hashable, Sendable {
        case engineManaged
        case userFixed
    }

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
    public let placement: Placement
    public let status: Status

    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        timeRange: TimeRange,
        placement: Placement,
        status: Status
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.timeRange = timeRange
        self.placement = placement
        self.status = status
    }

    public var contributesScheduledWork: Bool {
        status == .planned || status == .completed
    }

    public var occupiesTime: Bool {
        status != .missed && status != .cancelled
    }
}
