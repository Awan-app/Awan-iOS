import Foundation

public struct ActivityDay: Hashable, Sendable, Comparable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(
        year: Int,
        month: Int,
        day: Int
    ) {
        self.year = year
        self.month = month
        self.day = day
    }

    public static func < (
        lhs: ActivityDay,
        rhs: ActivityDay
    ) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        if lhs.month != rhs.month {
            return lhs.month < rhs.month
        }

        return lhs.day < rhs.day
    }
}
