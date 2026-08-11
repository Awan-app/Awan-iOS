import Common
import Domain
import Foundation

extension DailyZonesViewModel {
    var selectedTemplate: Template? {
        state.selectedTemplate
    }

    var selectedOverride: TemplateOverride? {
        state.selectedOverride
    }

    var selectedDateValue: Date {
        (state.selectedDate ?? calendarHelper.today).date(in: timeZone)
    }

    var minimumOverrideDate: Date { calendarHelper.startOfToday }

    var scheduleTimeZone: TimeZone { timeZone }

    var currentWeekDates: [Date] {
        calendarHelper.datesInWeek(containing: selectedDateValue)
    }

    var todayWeekday: TemplateWeekday? {
        calendarHelper.todayWeekday
    }

    func isDateToday(_ date: Date) -> Bool {
        calendarHelper.isToday(date)
    }

    func isDateSelected(_ date: Date) -> Bool {
        calendarHelper.overrideDate(from: date) == state.selectedDate
    }

    func hasOverride(on date: Date) -> Bool {
        let value = calendarHelper.overrideDate(from: date)
        return state.overrides.contains { $0.dateOfDay == value }
    }

    func weekdayAvailability(_ weekday: TemplateWeekday) -> TemplateWeekdayAvailability? {
        state.availability(for: weekday)
    }

    func isZoneOutsideActiveHours(_ zone: DailyZoneDraft) -> Bool {
        zoneEditor.isOutsideActiveHours(
            zone,
            wakeupTime: state.wakeupTime,
            sleepTime: state.sleepTime
        )
    }

    func formattedTime(_ time: LocalTime) -> String {
        calendarHelper.formattedTime(time)
    }

    func conflictSummary(for weekdays: Set<TemplateWeekday>) -> String? {
        let owners = state.weekdayAvailability
            .filter { weekdays.contains($0.weekday) && !$0.isAvailable }
            .compactMap(\.occupyingTemplateName)
        let names = Array(Set(owners)).sorted()
        guard !names.isEmpty else { return nil }
        return L10n.Templates.conflictingTemplates(
            ListFormatter.localizedString(byJoining: names)
        )
    }

    func zoneEditSummary(original: DailyZoneDraft, updated: DailyZoneDraft) -> String {
        var changes: [String] = []
        if original.name != updated.name {
            changes.append(
                L10n.Templates.zoneSummaryName(from: original.name, to: updated.name)
            )
        }
        if original.startTime != updated.startTime || original.endTime != updated.endTime {
            let originalRange = L10n.Templates.zoneTimeRange(
                formattedTime(original.startTime),
                formattedTime(original.endTime)
            )
            let updatedRange = L10n.Templates.zoneTimeRange(
                formattedTime(updated.startTime),
                formattedTime(updated.endTime)
            )
            changes.append(
                L10n.Templates.zoneSummaryTime(from: originalRange, to: updatedRange)
            )
        }
        if original.color != updated.color {
            changes.append(L10n.Templates.zoneSummaryColor)
        }
        return changes.joined(separator: "\n")
    }
}
