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
        guard let draft = zoneEditor.draft(
            from: form,
            original: original,
            categories: state.categories
        ) else { return }

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

    func loadCategories() {
        categoryCancellable?.cancel()
        state.categoryErrorMessage = nil
        categoryCancellable = useCases.fetchCategories.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    self?.state.categoryErrorMessage = error.localizedDescription
                },
                receiveValue: { [weak self] categories in
                    guard let self else { return }
                    state.categories = categories
                    if let selectedID = state.zoneForm?.selectedCategoryID,
                       !categories.contains(where: { $0.id == selectedID }) {
                        state.updateZoneForm { $0.selectedCategoryID = nil }
                    }
                }
            )
    }

    func createCategory(name: String) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !state.isCreatingCategory else { return }
        categoryCancellable?.cancel()
        state.isCreatingCategory = true
        state.categoryErrorMessage = nil
        defer { state.isCreatingCategory = false }
        do {
            let category = try await useCases.createCategory.execute(name: trimmedName)
            state.categories.removeAll { $0.id == category.id }
            state.categories.append(category)
            state.categories.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            state.updateZoneForm { $0.selectedCategoryID = category.id }
            state.categoryErrorMessage = nil
        } catch {
            state.categoryErrorMessage = error.localizedDescription
        }
    }

    func requestZoneDeletion(id: UUID) {
        guard let zone = state.zones.first(where: { $0.id == id }) else { return }
        state.dialog = .deleteZone(zone)
    }
}
