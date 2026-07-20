import Domain
import Foundation

public struct SessionRecord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let taskID: UUID
    public let zoneID: UUID?
    public let timeRange: TimeRange
    public let blocking: Bool
    public let status: Session.Status

    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        timeRange: TimeRange,
        blocking: Bool,
        status: Session.Status
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.timeRange = timeRange
        self.blocking = blocking
        self.status = status
    }
}
