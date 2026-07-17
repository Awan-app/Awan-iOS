import Foundation

public struct MoveSessionRequest: Hashable, Sendable {
    public let sessionID: UUID
    public let newTimeRange: TimeRange

    public init(sessionID: UUID, newTimeRange: TimeRange) {
        self.sessionID = sessionID
        self.newTimeRange = newTimeRange
    }
}
