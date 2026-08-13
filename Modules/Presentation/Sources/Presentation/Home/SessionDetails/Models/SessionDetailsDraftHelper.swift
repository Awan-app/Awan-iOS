import Common
import Domain
import Foundation

struct SessionDetailsDraftHelper {
    let presetDurations = [15, 30, 45, 60, 90, 120]

    func date(
        on day: Date,
        withTimeFrom time: Date,
        timeZoneIdentifier: String
    ) -> Date? {
        let calendar = calendar(timeZoneIdentifier: timeZoneIdentifier)
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(
            from: DateComponents(
                timeZone: calendar.timeZone,
                year: dayComponents.year,
                month: dayComponents.month,
                day: dayComponents.day,
                hour: timeComponents.hour,
                minute: timeComponents.minute
            )
        )
    }

    func adjusting(_ date: Date, byMinutes minutes: Int) -> Date? {
        Calendar(identifier: .gregorian).date(
            byAdding: .minute,
            value: minutes,
            to: date
        )
    }

    func end(start: Date, durationMinutes: Int) -> Date? {
        adjusting(start, byMinutes: durationMinutes)
    }

    func durationMinutes(for validation: SessionScheduleValidation) -> Int? {
        validation.timeRange?.durationMinutes
    }

    func validationMessage(
        for validation: SessionScheduleValidation
    ) -> String? {
        guard case .invalid = validation else { return nil }
        return L10n.Home.invalidSessionTimeRange
    }

    func selectedPreset(for durationMinutes: Int?) -> Int? {
        guard let durationMinutes,
              presetDurations.contains(durationMinutes) else {
            return nil
        }
        return durationMinutes
    }

    func isDirty(
        original: TimeRange,
        draftStart: Date,
        draftEnd: Date
    ) -> Bool {
        original.start != draftStart || original.end != draftEnd
    }

    func lockLabel(isLocked: Bool) -> String {
        isLocked ? L10n.Home.sessionLocked : L10n.Home.sessionUnlocked
    }

    private func calendar(timeZoneIdentifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        return calendar
    }
}
