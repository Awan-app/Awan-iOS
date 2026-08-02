import Common
import Domain
import Foundation

extension DailyZonesViewModel {
    func prepareCreationForm() {
        refreshAvailability()
        let minimumDate = calendarHelper.startOfToday
        state.creationForm = TemplateCreationForm(date: minimumDate)
        state.sheet = .createTemplate
    }

    func updateCreationDate(_ date: Date) {
        let minimumDate = calendarHelper.startOfToday
        state.updateCreationForm {
            $0.date = max(date, minimumDate)
            $0.conflictMessage = nil
        }
    }

    func toggleCreationWeekday(_ weekday: TemplateWeekday) {
        guard var form = state.creationForm,
              weekdayAvailability(weekday)?.isAvailable == true else { return }
        form.toggle(weekday)
        state.creationForm = form
    }

    func createItem() async {
        guard var form = state.creationForm else { return }
        form.conflictMessage = nil
        form.isSubmitting = true
        state.creationForm = form
        do {
            switch form.kind {
            case .weekly:
                let template = try await useCases.createTemplate.execute(
                    name: form.trimmedName,
                    daysOfWeek: form.weekdays,
                    zones: []
                )
                state.templates.append(template)
                state.templates = DailyZonesState.sortedTemplates(state.templates)
                state.mode = .weekly
                state.selectedTemplateID = template.id
            case .override:
                let date = calendarHelper.overrideDate(from: form.date)
                let templateOverride = try await useCases.createOverride.execute(
                    name: form.trimmedName,
                    dateOfDay: date,
                    minimumDate: calendarHelper.today,
                    zones: weeklyZones(for: date)
                )
                state.overrides.append(templateOverride)
                state.overrides.sort { $0.dateOfDay < $1.dateOfDay }
                state.mode = .override
                state.selectedDate = templateOverride.dateOfDay
            }
            state.sheet = nil
            state.creationForm = nil
            refreshAvailability()
            refreshZones()
        } catch TemplateManagementError.dayAlreadyAssigned {
            await refreshTemplatesForConflict()
            let message = conflictSummary(for: form.weekdays)
                ?? L10n.Templates.daysAssignedElsewhere
            state.updateCreationForm {
                $0.isSubmitting = false
                $0.conflictMessage = message
            }
        } catch {
            let errorMessage = DailyZonesErrorMessageMapper.message(for: error)
            state.updateCreationForm {
                $0.isSubmitting = false
                $0.conflictMessage = errorMessage
            }
        }
    }

    func presentTemplateEditor() {
        guard let template = selectedTemplate else { return }
        refreshAvailability(excluding: template.id)
        state.templateForm = TemplateDetailsForm(
            id: template.id,
            name: template.name,
            weekdays: template.daysOfWeek
        )
        state.sheet = .editTemplate
    }

    func toggleTemplateWeekday(_ weekday: TemplateWeekday) {
        guard var form = state.templateForm else { return }
        let isOwnDay = selectedTemplate?.daysOfWeek.contains(weekday) == true
        guard isOwnDay || weekdayAvailability(weekday)?.isAvailable == true else { return }
        form.toggle(weekday)
        state.templateForm = form
    }

    func updateTemplateDetails() async {
        guard var form = state.templateForm else { return }
        form.isSubmitting = true
        state.templateForm = form
        do {
            let updated = try await useCases.updateTemplateDetails.execute(
                id: form.id,
                name: form.trimmedName,
                daysOfWeek: form.weekdays
            )
            state.replaceTemplate(updated)
            state.sheet = nil
            state.templateForm = nil
            refreshAvailability()
            refreshZones()
        } catch TemplateManagementError.dayAlreadyAssigned {
            await refreshTemplatesForConflict()
            let message = conflictSummary(for: form.weekdays)
                ?? L10n.Templates.daysNowUnavailable
            state.updateTemplateForm {
                $0.isSubmitting = false
                $0.conflictMessage = message
            }
        } catch {
            let errorMessage = DailyZonesErrorMessageMapper.message(for: error)
            state.updateTemplateForm {
                $0.isSubmitting = false
                $0.conflictMessage = errorMessage
            }
        }
    }

    func presentOverrideEditor() {
        guard let templateOverride = selectedOverride else { return }
        state.creationForm = TemplateCreationForm(
            kind: .override,
            name: templateOverride.name ?? "",
            date: templateOverride.dateOfDay.date(in: timeZone)
        )
        state.sheet = .editOverride
    }

    func updateOverrideDetails() async {
        guard var form = state.creationForm,
              let templateOverride = selectedOverride else { return }
        let date = calendarHelper.overrideDate(from: form.date)
        form.isSubmitting = true
        state.creationForm = form
        do {
            let updated = try await useCases.updateOverrideDetails.execute(
                id: templateOverride.id,
                name: form.trimmedName,
                dateOfDay: date,
                minimumDate: calendarHelper.today
            )
            state.replaceOverride(updated)
            state.selectedDate = updated.dateOfDay
            state.sheet = nil
            state.creationForm = nil
            refreshZones()
        } catch {
            let errorMessage = DailyZonesErrorMessageMapper.message(for: error)
            state.updateCreationForm {
                $0.isSubmitting = false
                $0.conflictMessage = errorMessage
            }
        }
    }

    func requestTemplateDeletion() {
        guard let template = selectedTemplate else { return }
        state.sheet = nil
        state.templateForm = nil
        Task {
            await Task.yield()
            state.dialog = .deleteTemplate(template)
        }
    }

    func requestOverrideDeletion() {
        guard let templateOverride = selectedOverride else { return }
        state.sheet = nil
        state.creationForm = nil
        Task {
            await Task.yield()
            state.dialog = .deleteOverride(templateOverride)
        }
    }
}
