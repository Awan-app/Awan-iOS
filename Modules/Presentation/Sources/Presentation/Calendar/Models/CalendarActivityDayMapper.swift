import Domain
import Foundation

struct CalendarActivityDayMapper {
    let calendar: Calendar

    func updating(calendar: Calendar) -> CalendarActivityDayMapper {
        CalendarActivityDayMapper(calendar: calendar)
    }

    func activityRange(
        for month: Date
    ) -> (start: ActivityDay, end: ActivityDay)? {
        let start = CalendarMonthGrid.startOfMonth(
            containing: month,
            calendar: calendar
        )

        guard let dayRange = calendar.range(of: .day, in: .month, for: start),
              let end = calendar.date(
                  byAdding: .day,
                  value: dayRange.count - 1,
                  to: start
              )
        else {
            return nil
        }

        return (activityDay(from: start), activityDay(from: end))
    }

    func calendarDayKey(from day: ActivityDay) -> CalendarDayKey {
        CalendarDayKey(year: day.year, month: day.month, day: day.day)
    }

    private func activityDay(from date: Date) -> ActivityDay {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return ActivityDay(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }
}
