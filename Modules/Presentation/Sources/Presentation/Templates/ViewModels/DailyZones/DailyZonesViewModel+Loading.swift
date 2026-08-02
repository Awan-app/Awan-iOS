import Common
import Domain
import Foundation

extension DailyZonesViewModel {
    func load() async {
        state.phase = .loading
        state.errorMessage = nil
        do {
            async let profileTask = useCases.getUserProfile.execute()
            async let templateTask = useCases.fetchTemplates.execute()
            async let overrideTask = useCases.fetchOverrides.execute()
            let (profile, templates, overrides) = try await (
                profileTask,
                templateTask,
                overrideTask
            )

            state.wakeupTime = profile.preferences.wakeupTime
            state.sleepTime = profile.preferences.sleepTime
            state.timeZoneIdentifier = profile.preferences.timezone
            state.templates = DailyZonesState.sortedTemplates(templates)
            state.overrides = overrides.sorted { $0.dateOfDay < $1.dateOfDay }
            state.selectedDate = calendarHelper.today
            state.selectedTemplateID = state.preferredTemplateID(for: todayWeekday)
            refreshAvailability()
            refreshZones()
            state.phase = .content
        } catch {
            state.phase = .failure(DailyZonesErrorMessageMapper.message(for: error))
        }
    }

    func refreshZones() {
        let zones: [Zone]
        switch state.mode {
        case .weekly:
            zones = selectedTemplate?.zones ?? []
        case .override:
            zones = selectedOverride?.zones ?? weeklyZones(for: state.selectedDate)
        }
        state.setZones(zones)
    }

    func weeklyZones(for date: TemplateOverrideDate?) -> [Zone] {
        guard let date else { return [] }
        return useCases.manageSchedule.weeklyZones(
            for: date,
            timeZone: timeZone,
            templates: state.templates
        )
    }

    func refreshAvailability(excluding id: UUID? = nil) {
        state.weekdayAvailability = useCases.resolveWeekdays.execute(
            templates: state.templates,
            excludingTemplateID: id
        )
    }

    func refreshTemplatesForConflict() async {
        if let templates = try? await useCases.fetchTemplates.execute() {
            state.templates = DailyZonesState.sortedTemplates(templates)
            refreshAvailability(excluding: state.templateForm?.id)
        }
    }
}
