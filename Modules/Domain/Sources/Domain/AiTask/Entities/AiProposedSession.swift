import Foundation

public struct AiProposedSession: Hashable, Sendable {
    public let zoneID: UUID?
    public let timeRange: TimeRange
    public let status: String

    public init(
        zoneID: UUID?,
        timeRange: TimeRange,
        status: String
    ) {
        self.zoneID = zoneID
        self.timeRange = timeRange
        self.status = status
    }
}
