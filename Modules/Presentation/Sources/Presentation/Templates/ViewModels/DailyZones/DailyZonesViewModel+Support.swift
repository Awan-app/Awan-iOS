import Foundation

extension DailyZonesViewModel {
    var timeZone: TimeZone {
        TimeZone(identifier: state.timeZoneIdentifier) ?? .current
    }

    var calendarHelper: DailyZonesCalendar {
        DailyZonesCalendar(timeZone: timeZone)
    }

    var zoneEditor: DailyZonesZoneEditor {
        DailyZonesZoneEditor(
            manageSchedule: useCases.manageSchedule,
            calendar: calendarHelper
        )
    }
}
