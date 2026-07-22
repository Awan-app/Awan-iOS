import Foundation

enum LocalDateKey {
    static func value(for date: Date) -> String {
        value(for: date, calendar: calendar)
    }

    static func value(for date: Date, timeZoneID: String) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        return value(for: date, calendar: calendar)
    }

    private static func value(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    static func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func weekDay(for date: Date) -> Int {
        calendar.component(.weekday, from: date)
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }
}
