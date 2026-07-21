import Foundation

public struct MoveSessionRequest: Hashable, Sendable {
    public let sessionID: UUID
    public let newTimeRange: TimeRange
    public let selectedDay: Date

    public init(sessionID: UUID, newTimeRange: TimeRange, selectedDay: Date) {
        self.sessionID = sessionID
        self.newTimeRange = newTimeRange
        self.selectedDay = selectedDay
    }
}
