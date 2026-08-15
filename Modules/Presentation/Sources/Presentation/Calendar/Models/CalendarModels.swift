import Foundation

enum CalendarMonthNavigationDirection: Equatable {
    case previous
    case next
}

struct CalendarGoalUIModel: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String?
    let deadline: Date?
    let deadlineText: String

    var hasDeadline: Bool {
        deadline != nil
    }
}

// MARK: - Presentation-layer day key (no Domain import in views)

struct CalendarDayKey: Hashable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )
        self.init(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }
}

// MARK: - Grid cell (carries adjacency information)

struct CalendarDayCell: Identifiable, Equatable {
    let date: Date
    let isInDisplayedMonth: Bool

    var id: Date { date }
}

// MARK: - Screen state

struct CalendarScreenState {
    var isLoading: Bool
    var goals: [CalendarGoalUIModel]
    var activityDays: Set<CalendarDayKey>
    var selectedDate: Date
    var displayedMonth: Date
    var monthNavigationDirection: CalendarMonthNavigationDirection
    var failureMessage: String?

    static func initial(date: Date, calendar: Calendar) -> CalendarScreenState {
        CalendarScreenState(
            isLoading: false,
            goals: [],
            activityDays: [],
            selectedDate: calendar.startOfDay(for: date),
            displayedMonth: CalendarMonthGrid.startOfMonth(
                containing: date,
                calendar: calendar
            ),
            monthNavigationDirection: .next,
            failureMessage: nil
        )
    }
}

// MARK: - Month grid helpers

enum CalendarMonthGrid {
    static func startOfMonth(containing date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }

    /// Returns the visible grid as week rows, each containing exactly 7 cells.
    /// Leading and trailing cells belong to adjacent months.
    static func weeks(
        in month: Date,
        calendar: Calendar
    ) -> [[CalendarDayCell]] {
        let monthStart = startOfMonth(containing: month, calendar: calendar)

        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingCount = (weekday - calendar.firstWeekday + 7) % 7

        guard let gridStart = calendar.date(
            byAdding: .day,
            value: -leadingCount,
            to: monthStart
        ) else {
            return []
        }

        let requiredCells = leadingCount + dayRange.count
        let rowCount = Int(ceil(Double(requiredCells) / 7.0))
        let totalCells = rowCount * 7

        let cells: [CalendarDayCell] = (0..<totalCells).compactMap { offset in
            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: gridStart
            ) else { return nil }

            return CalendarDayCell(
                date: date,
                isInDisplayedMonth: calendar.isDate(
                    date,
                    equalTo: monthStart,
                    toGranularity: .month
                )
            )
        }

        return stride(from: 0, to: cells.count, by: 7).map { index in
            Array(cells[index..<min(index + 7, cells.count)])
        }
    }

    static func weekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = max(0, min(symbols.count - 1, calendar.firstWeekday - 1))
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }
}
