import Domain
import Foundation

extension DailyZonesState {
    var selectedTemplate: Template? {
        templates.first { $0.id == selectedTemplateID }
    }

    var selectedOverride: TemplateOverride? {
        guard let selectedDate else { return nil }
        return overrides.first { $0.dateOfDay == selectedDate }
    }

    func availability(for weekday: TemplateWeekday) -> TemplateWeekdayAvailability? {
        weekdayAvailability.first { $0.weekday == weekday }
    }

    func preferredTemplateID(for weekday: TemplateWeekday?) -> UUID? {
        guard let weekday else { return templates.first?.id }
        return templates.first { $0.daysOfWeek.contains(weekday) }?.id
            ?? templates.first?.id
    }

    mutating func closeSheet() {
        sheet = nil
        creationForm = nil
        templateForm = nil
        zoneForm = nil
    }

    mutating func updateCreationForm(_ update: (inout TemplateCreationForm) -> Void) {
        guard var form = creationForm else { return }
        update(&form)
        creationForm = form
    }

    mutating func updateTemplateForm(_ update: (inout TemplateDetailsForm) -> Void) {
        guard var form = templateForm else { return }
        update(&form)
        templateForm = form
    }

    mutating func updateZoneForm(_ update: (inout ZoneEditorForm) -> Void) {
        guard var form = zoneForm else { return }
        update(&form)
        zoneForm = form
    }

    mutating func replaceTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        templates.append(template)
        templates = Self.sortedTemplates(templates)
    }

    mutating func replaceOverride(_ templateOverride: TemplateOverride) {
        overrides.removeAll { $0.id == templateOverride.id }
        overrides.append(templateOverride)
        overrides.sort { $0.dateOfDay < $1.dateOfDay }
    }

    mutating func setZones(_ values: [Zone]) {
        zones = values
            .sorted { $0.startTime < $1.startTime }
            .map(DailyZoneDraft.init)
        baselineZones = zones
        zoneDrag = nil
    }

    mutating func dragZone(
        id: UUID,
        translation: Double,
        rowStride: Double,
        using manageSchedule: any ManageDailyZoneScheduleUseCase
    ) {
        guard rowStride > 0,
              var currentIndex = zones.firstIndex(where: { $0.id == id }) else { return }

        var drag = zoneDrag?.zoneID == id
            ? zoneDrag ?? DailyZoneDragState(
                zoneID: id,
                offset: 0,
                cumulativeTranslation: 0
            )
            : DailyZoneDragState(zoneID: id, offset: 0, cumulativeTranslation: 0)
        drag.offset = translation - drag.cumulativeTranslation

        while drag.offset >= rowStride, currentIndex < zones.count - 1 {
            swapZoneTimeSlots(at: currentIndex, with: currentIndex + 1, using: manageSchedule)
            currentIndex += 1
            drag.cumulativeTranslation += rowStride
            drag.offset -= rowStride
        }

        while drag.offset <= -rowStride, currentIndex > 0 {
            swapZoneTimeSlots(at: currentIndex, with: currentIndex - 1, using: manageSchedule)
            currentIndex -= 1
            drag.cumulativeTranslation -= rowStride
            drag.offset += rowStride
        }

        zoneDrag = drag
    }

    static func sortedTemplates(_ templates: [Template]) -> [Template] {
        templates.sorted { lhs, rhs in
            let left = lhs.daysOfWeek.compactMap(TemplateWeekday.allCases.firstIndex).min() ?? 7
            let right = rhs.daysOfWeek.compactMap(TemplateWeekday.allCases.firstIndex).min() ?? 7
            return left == right
                ? lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                : left < right
        }
    }

    private mutating func swapZoneTimeSlots(
        at sourceIndex: Int,
        with destinationIndex: Int,
        using manageSchedule: any ManageDailyZoneScheduleUseCase
    ) {
        let draftsByID = Dictionary(uniqueKeysWithValues: zones.map { ($0.id, $0) })
        let swapped = manageSchedule.swapZones(
            zones.map(\.creationZone),
            at: sourceIndex,
            with: destinationIndex
        )
        zones = swapped.compactMap { zone in
            guard var draft = draftsByID[zone.id] else { return nil }
            draft.startTime = zone.startTime
            draft.endTime = zone.endTime
            return draft
        }
    }
}

extension TemplateCreationForm {
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func toggle(_ weekday: TemplateWeekday) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        } else {
            weekdays.insert(weekday)
        }
        conflictMessage = nil
    }
}

extension TemplateDetailsForm {
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func toggle(_ weekday: TemplateWeekday) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        } else {
            weekdays.insert(weekday)
        }
        conflictMessage = nil
    }
}

extension ZoneEditorForm {
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedName.isEmpty
            && startTime < endTime
            && overlapMessage == nil
            && selectedCategoryID != nil
    }
}
