import Foundation

public struct TimeRange: Hashable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start < end else {
            throw SchedulingError.invalidTimeRange
        }

        self.start = start
        self.end = end
    }

    public var durationMinutes: Int {
        Int(end.timeIntervalSince(start) / 60)
    }

    public func overlaps(_ other: TimeRange) -> Bool {
        start < other.end && other.start < end
    }
}
