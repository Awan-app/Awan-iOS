import Foundation

enum CalendarAction {
    case appeared(calendar: Calendar, locale: Locale)
    case refresh
    case selectDate(Date)
    case showPreviousMonth
    case showNextMonth
    case dismissError
}
