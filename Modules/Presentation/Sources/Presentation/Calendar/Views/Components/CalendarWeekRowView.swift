import SwiftUI

struct CalendarWeekRowView: View {
    let week: [CalendarDayCell]
    let selectedDate: Date
    let activityDays: Set<CalendarDayKey>
    let deadlineCounts: [CalendarDayKey: Int]
    let calendar: Calendar
    let locale: Locale
    let onSelectDate: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(week) { cell in
                let key = CalendarDayKey(date: cell.date, calendar: calendar)

                CalendarDayCellView(
                    cell: cell,
                    isSelected: calendar.isDate(
                        cell.date,
                        inSameDayAs: selectedDate
                    ),
                    isToday: calendar.isDateInToday(cell.date),
                    isActivity: cell.isInDisplayedMonth && activityDays.contains(key),
                    deadlineCount: cell.isInDisplayedMonth
                        ? deadlineCounts[key, default: 0]
                        : 0,
                    locale: locale,
                    onSelectDate: onSelectDate
                )
                .frame(maxWidth: .infinity)
                .frame(height: CalendarMonthLayout.dayRowHeight)
            }
        }
    }
}
