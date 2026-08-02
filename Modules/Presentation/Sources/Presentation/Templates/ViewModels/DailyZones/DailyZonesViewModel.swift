import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class DailyZonesViewModel {
    var state = DailyZonesState()

    let useCases: DailyZonesUseCases

    public init(useCases: DailyZonesUseCases) {
        self.useCases = useCases
    }

    func send(_ action: DailyZonesAction) {
        switch action {
        case .appeared, .retry:
            Task { await load() }
        case .selectMode(let mode):
            request(.mode(mode))
        case .selectTemplate(let id):
            request(.template(id))
        case .selectDate(let date):
            state.weekNavigationDirection = date < selectedDateValue ? .backward : .forward
            request(.date(calendarHelper.overrideDate(from: date)))
        case .previousWeek:
            state.weekNavigationDirection = .backward
            moveSelectedDate(by: -7)
        case .nextWeek:
            state.weekNavigationDirection = .forward
            moveSelectedDate(by: 7)
        case .requestDismiss:
            request(.dismiss)
        case .dismissCompleted:
            state.shouldDismiss = false
        case .presentCreation:
            prepareCreationForm()
        case .dismissSheet:
            state.closeSheet()
        case .setCreationKind(let kind):
            state.updateCreationForm {
                $0.kind = kind
                $0.conflictMessage = nil
            }
        case .setCreationName(let name):
            state.updateCreationForm { $0.name = name }
        case .toggleCreationWeekday(let weekday):
            toggleCreationWeekday(weekday)
        case .setCreationDate(let date):
            updateCreationDate(date)
        case .submitCreation:
            Task { await createItem() }
        case .presentTemplateEditor:
            presentTemplateEditor()
        case .setTemplateName(let name):
            state.updateTemplateForm { $0.name = name }
        case .toggleTemplateWeekday(let weekday):
            toggleTemplateWeekday(weekday)
        case .submitTemplateDetails:
            Task { await updateTemplateDetails() }
        case .presentOverrideEditor:
            presentOverrideEditor()
        case .submitOverrideDetails:
            Task { await updateOverrideDetails() }
        case .requestDeleteTemplate:
            requestTemplateDeletion()
        case .requestDeleteOverride:
            requestOverrideDeletion()
        case .presentAddZone:
            presentZoneEditor(zone: nil)
        case .presentEditZone(let id):
            presentZoneEditor(zone: state.zones.first { $0.id == id })
        case .setZoneName(let name):
            state.updateZoneForm { $0.name = name }
        case .setZoneColor(let index):
            state.updateZoneForm { $0.selectedColorIndex = index }
        case .setZoneStart(let date):
            state.updateZoneForm { $0.startTime = date }
            validateZoneForm()
        case .setZoneEnd(let date):
            state.updateZoneForm { $0.endTime = date }
            validateZoneForm()
        case .submitZoneForm:
            submitZoneForm()
        case .requestDeleteZone(let id):
            requestZoneDeletion(id: id)
        case .dragZone(let id, let translation, let rowStride):
            state.dragZone(
                id: id,
                translation: translation,
                rowStride: rowStride,
                using: useCases.manageSchedule
            )
        case .endZoneDrag:
            state.zoneDrag = nil
        case .confirmDialog:
            confirmDialog()
        case .discardAndContinue:
            discardChangesAndContinue()
        case .cancelDialog:
            state.dialog = nil
        case .save:
            Task { await save() }
        case .dismissError:
            state.errorMessage = nil
        }
    }
}
