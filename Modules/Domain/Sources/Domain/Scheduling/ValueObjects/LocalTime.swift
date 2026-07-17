import Foundation

public struct LocalTime: Hashable, Sendable, Comparable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) throws {
        guard (0...23).contains(hour), (0...59).contains(minute) else {
            throw SchedulingError.invalidLocalTime(hour: hour, minute: minute)
        }

        self.hour = hour
        self.minute = minute
    }

    public var minutesSinceMidnight: Int {
        (hour * 60) + minute
    }

    public static func < (lhs: LocalTime, rhs: LocalTime) -> Bool {
        lhs.minutesSinceMidnight < rhs.minutesSinceMidnight
    }
}
