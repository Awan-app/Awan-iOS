import Foundation

public protocol UUIDGenerating: Sendable {
    func makeUUID() -> UUID
}

public struct SystemUUIDGenerator: UUIDGenerating {
    public init() {}

    public func makeUUID() -> UUID {
        UUID()
    }
}

extension Session {
    func replacing(
        zoneID: UUID?? = nil,
        timeRange: TimeRange? = nil,
        placement: Placement? = nil,
        status: Status? = nil
    ) -> Session {
        Session(
            id: id,
            taskID: taskID,
            zoneID: zoneID ?? self.zoneID,
            timeRange: timeRange ?? self.timeRange,
            placement: placement ?? self.placement,
            status: status ?? self.status
        )
    }
}
