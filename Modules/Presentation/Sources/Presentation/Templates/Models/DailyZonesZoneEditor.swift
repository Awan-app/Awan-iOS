import Common
import Domain
import Foundation

struct DailyZonesZoneEditor {
    let manageSchedule: any ManageDailyZoneScheduleUseCase
    let calendar: DailyZonesCalendar

    func form(
        for zone: DailyZoneDraft?,
        existingZones: [DailyZoneDraft],
        wakeupTime: LocalTime?,
        sleepTime: LocalTime?
    ) -> ZoneEditorForm {
        let interval = zone.map {
            (calendar.date(from: $0.startTime), calendar.date(from: $0.endTime))
        } ?? firstAvailableInterval(wakeupTime: wakeupTime, zones: existingZones)
        let form = ZoneEditorForm(
            editingID: zone?.id,
            name: zone?.name ?? "",
            selectedColorIndex: zone.map(colorIndex) ?? 0,
            startTime: interval.0,
            endTime: interval.1,
            selectedCategoryID: zone?.category?.id
        )
        return validated(
            form,
            existingZones: existingZones,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    func validated(
        _ form: ZoneEditorForm,
        existingZones: [DailyZoneDraft],
        wakeupTime: LocalTime?,
        sleepTime: LocalTime?
    ) -> ZoneEditorForm {
        var form = form
        let overlap = form.startTime < form.endTime && manageSchedule.isOverlapping(
            start: validationTime(form.startTime),
            end: validationTime(form.endTime),
            in: existingZones.filter { $0.id != form.editingID }.map(\.creationZone),
            excludingID: nil
        )
        form.overlapMessage = overlap ? L10n.Templates.zoneOverlap : nil
        if let wakeupTime, let sleepTime {
            form.outsideHoursWarning = manageSchedule.isOutsideActiveHours(
                start: form.startTime,
                end: form.endTime,
                wakeupTime: calendar.date(from: wakeupTime),
                sleepTime: calendar.date(from: sleepTime)
            )
        }
        return form
    }

    func draft(
        from form: ZoneEditorForm,
        original: DailyZoneDraft?,
        categories: [TaskCategory]
    ) -> DailyZoneDraft? {
        guard form.isValid,
              ZoneColorPalette.colors.indices.contains(form.selectedColorIndex),
              let start = calendar.localTime(from: form.startTime),
              let end = calendar.localTime(from: form.endTime),
              let color = color(at: form.selectedColorIndex),
              let category = categories.first(where: { $0.id == form.selectedCategoryID }) else {
            return nil
        }
        return DailyZoneDraft(
            id: original?.id ?? UUID(),
            serverID: original?.serverID,
            name: form.trimmedName,
            color: color,
            startTime: start,
            endTime: end,
            category: category
        )
    }

    func isOutsideActiveHours(
        _ zone: DailyZoneDraft,
        wakeupTime: LocalTime?,
        sleepTime: LocalTime?
    ) -> Bool {
        guard let wakeupTime, let sleepTime else { return false }
        return manageSchedule.isOutsideActiveHours(
            start: calendar.date(from: zone.startTime),
            end: calendar.date(from: zone.endTime),
            wakeupTime: calendar.date(from: wakeupTime),
            sleepTime: calendar.date(from: sleepTime)
        )
    }

    private func firstAvailableInterval(
        wakeupTime: LocalTime?,
        zones: [DailyZoneDraft]
    ) -> (Date, Date) {
        let wakeup = wakeupTime.map(calendar.date(from:)) ?? calendar.startOfToday
        let interval = manageSchedule.firstAvailableInterval(
            wakeupTime: wakeup,
            existingZones: zones.map(\.creationZone)
        )
        return (interval.start, interval.end)
    }

    private func colorIndex(_ zone: DailyZoneDraft) -> Int {
        let hex = zone.color.hex.uppercased()
        return ZoneColorPalette.colors.firstIndex {
            colorHex(red: $0.red, green: $0.green, blue: $0.blue) == hex
        } ?? 0
    }

    private func color(at index: Int) -> ZoneColor? {
        let value = ZoneColorPalette.colors[index]
        return try? ZoneColor(
            hex: colorHex(red: value.red, green: value.green, blue: value.blue)
        )
    }

    private func colorHex(red: Double, green: Double, blue: Double) -> String {
        String(
            format: "#%02X%02X%02X",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255))
        )
    }

    private func validationTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
