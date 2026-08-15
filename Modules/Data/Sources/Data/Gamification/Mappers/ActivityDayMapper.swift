import Domain
import Foundation

enum ActivityDayMapper {
    static func map(_ values: [String]) throws -> Set<ActivityDay> {
        try Set(values.map(activityDay(from:)))
    }

    static func string(from day: ActivityDay) -> String {
        String(
            format: "%04d-%02d-%02d",
            day.year,
            day.month,
            day.day
        )
    }

    static func activityDay(from value: String) throws -> ActivityDay {
        let bytes = Array(value.utf8)
        let digitIndexes = [0, 1, 2, 3, 5, 6, 8, 9]

        guard bytes.count == 10,
              bytes[4] == 45,
              bytes[7] == 45,
              digitIndexes.allSatisfy({ bytes[$0].isASCIIDigit })
        else {
            throw GamificationError.invalidActivityDate(value)
        }

        let parts = value.split(separator: "-")

        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else {
            throw GamificationError.invalidActivityDate(value)
        }

        let result = ActivityDay(year: year, month: month, day: day)

        guard isValid(result) else {
            throw GamificationError.invalidActivityDate(value)
        }

        return result
    }

    // UTC-only — used strictly for date arithmetic, not timezone representation.
    static func date(from day: ActivityDay) throws -> Date {
        var components = DateComponents()
        components.calendar = gregorianCalendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = day.year
        components.month = day.month
        components.day = day.day

        guard let date = gregorianCalendar.date(from: components) else {
            throw GamificationError.invalidActivityDate(string(from: day))
        }

        return date
    }

    static func activityDay(from date: Date) -> ActivityDay {
        let components = gregorianCalendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        return ActivityDay(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }

    private static func isValid(_ day: ActivityDay) -> Bool {
        guard let date = try? date(from: day) else {
            return false
        }
        let reconstructed = activityDay(from: date)
        return reconstructed == day
    }

    static var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}

private extension UInt8 {
    var isASCIIDigit: Bool {
        (48...57).contains(self)
    }
}
