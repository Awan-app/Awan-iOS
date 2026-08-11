import Common
import Domain

extension DailyZonesViewModel {
    func confirmDialog() {
        guard let dialog = state.dialog else { return }
        state.dialog = nil
        switch dialog {
        case .deleteZone(let zone):
            state.zones.removeAll { $0.id == zone.id }
        case .applyZoneEdit(_, let updated):
            if let index = state.zones.firstIndex(where: { $0.id == updated.id }) {
                state.zones[index] = updated
                state.zones.sort { $0.startTime < $1.startTime }
            }
        case .unsavedChanges(let destination):
            Task { await save(then: destination) }
        case .deleteTemplate(let template):
            Task { await deleteTemplate(template) }
        case .deleteOverride(let templateOverride):
            Task { await deleteOverride(templateOverride) }
        }
    }

    func discardChangesAndContinue() {
        guard case .unsavedChanges(let destination) = state.dialog else { return }
        state.dialog = nil
        state.zones = state.baselineZones
        apply(destination)
    }

    func save(then destination: DailyZonesDestination? = nil) async {
        guard !state.isSaving else { return }
        guard state.areZonesCategorized else {
            state.errorMessage = L10n.Schedule.chooseCategory
            return
        }
        switch state.mode {
        case .weekly where selectedTemplate == nil:
            return
        case .override where selectedOverride == nil:
            return
        default:
            break
        }
        state.isSaving = true
        state.errorMessage = nil
        do {
            switch state.mode {
            case .weekly:
                guard let template = selectedTemplate else { return }
                let updated = try await useCases.updateTemplateZones.execute(
                    id: template.id,
                    zones: state.zones.map(\.mutation)
                )
                state.replaceTemplate(updated)
            case .override:
                guard let templateOverride = selectedOverride else { return }
                let updated = try await useCases.updateOverrideZones.execute(
                    id: templateOverride.id,
                    zones: state.zones.map(\.mutation)
                )
                state.replaceOverride(updated)
            }
            refreshZones()
            state.isSaving = false
            if let destination { apply(destination) }
        } catch {
            state.isSaving = false
            state.errorMessage = DailyZonesErrorMessageMapper.message(for: error)
        }
    }

    func deleteTemplate(_ template: Template) async {
        do {
            try await useCases.deleteTemplate.execute(id: template.id)
            state.templates.removeAll { $0.id == template.id }
            state.selectedTemplateID = state.preferredTemplateID(for: todayWeekday)
            state.sheet = nil
            state.templateForm = nil
            refreshAvailability()
            refreshZones()
        } catch {
            state.errorMessage = DailyZonesErrorMessageMapper.message(for: error)
        }
    }

    func deleteOverride(_ templateOverride: TemplateOverride) async {
        do {
            try await useCases.deleteOverride.execute(id: templateOverride.id)
            state.overrides.removeAll { $0.id == templateOverride.id }
            state.sheet = nil
            state.creationForm = nil
            refreshZones()
        } catch {
            state.errorMessage = DailyZonesErrorMessageMapper.message(for: error)
        }
    }
}
