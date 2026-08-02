import Domain
import Foundation

extension DailyZonesViewModel {
    func presentZoneEditor(zone: DailyZoneDraft?) {
        state.zoneForm = zoneEditor.form(
            for: zone,
            existingZones: state.zones,
            wakeupTime: state.wakeupTime,
            sleepTime: state.sleepTime
        )
        state.sheet = .zoneEditor
    }

    func validateZoneForm() {
        guard let form = state.zoneForm else { return }
        state.zoneForm = zoneEditor.validated(
            form,
            existingZones: state.zones,
            wakeupTime: state.wakeupTime,
            sleepTime: state.sleepTime
        )
    }

    func submitZoneForm() {
        guard let form = state.zoneForm else { return }
        let original = form.editingID.flatMap { id in
            state.zones.first { $0.id == id }
        }
        guard let draft = zoneEditor.draft(from: form, original: original) else { return }

        if let original {
            state.sheet = nil
            state.zoneForm = nil
            state.dialog = .applyZoneEdit(original: original, updated: draft)
        } else {
            state.zones.append(draft)
            state.zones.sort { $0.startTime < $1.startTime }
            state.sheet = nil
            state.zoneForm = nil
        }
    }

    func requestZoneDeletion(id: UUID) {
        guard let zone = state.zones.first(where: { $0.id == id }) else { return }
        state.dialog = .deleteZone(zone)
    }
}
