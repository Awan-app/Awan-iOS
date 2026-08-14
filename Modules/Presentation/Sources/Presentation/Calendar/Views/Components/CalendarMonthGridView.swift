import SwiftUI

struct CalendarMonthGridView: View {
    let weeks: [[CalendarDayCell]]
    let selectedDate: Date
    let activityDays: Set<CalendarDayKey>
    let deadlineCounts: [CalendarDayKey: Int]
    let calendar: Calendar
    let locale: Locale
    let onSelectDate: (Date) -> Void

    var body: some View {
        VStack(spacing: CalendarMonthLayout.weekSpacing) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                CalendarWeekRowView(
                    week: week,
                    selectedDate: selectedDate,
                    activityDays: activityDays,
                    deadlineCounts: deadlineCounts,
                    calendar: calendar,
                    locale: locale,
                    onSelectDate: onSelectDate
                )
            }
        }
    }
}

enum CalendarMonthLayout {
    static let dayRowHeight: CGFloat = 42
    static let selectedDaySize: CGFloat = 34
    static let deadlineDotSize: CGFloat = 4
    static let weekSpacing: CGFloat = 1
}
