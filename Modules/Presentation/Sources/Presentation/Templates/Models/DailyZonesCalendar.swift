import Domain
import Foundation

struct DailyZonesCalendar {
    let timeZone: TimeZone

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    var today: TemplateOverrideDate {
        TemplateOverrideDate(date: Date(), timeZone: timeZone)
    }

    var startOfToday: Date {
        calendar.startOfDay(for: Date())
    }

    var todayWeekday: TemplateWeekday? {
        TemplateWeekday(calendarWeekday: calendar.component(.weekday, from: Date()))
    }

    func overrideDate(from date: Date) -> TemplateOverrideDate {
        TemplateOverrideDate(date: date, timeZone: timeZone)
    }

    func date(from time: LocalTime) -> Date {
        calendar.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: startOfToday
        ) ?? startOfToday
    }

    func localTime(from date: Date) -> LocalTime? {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return try? LocalTime(hour: hour, minute: minute)
    }

    func datesInWeek(containing date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    func addingDays(_ dayCount: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .day, value: dayCount, to: date)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }

    func formattedTime(_ time: LocalTime) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = timeZone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date(from: time))
    }
}
