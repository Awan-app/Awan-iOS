import Domain

extension DailyZonesViewModel {
    func request(_ destination: DailyZonesDestination) {
        guard state.isDirty else {
            apply(destination)
            return
        }
        state.dialog = .unsavedChanges(destination)
    }

    func apply(_ destination: DailyZonesDestination) {
        switch destination {
        case .mode(let mode):
            state.mode = mode
            refreshZones()
        case .template(let id):
            state.selectedTemplateID = id
            refreshAvailability()
            refreshZones()
        case .date(let date):
            state.selectedDate = date
            refreshZones()
        case .dismiss:
            state.shouldDismiss = true
        }
    }

    func moveSelectedDate(by dayCount: Int) {
        guard !state.isDirty else {
            let target = calendarHelper.addingDays(dayCount, to: selectedDateValue)
                ?? selectedDateValue
            request(.date(calendarHelper.overrideDate(from: target)))
            return
        }
        guard let date = calendarHelper.addingDays(dayCount, to: selectedDateValue) else { return }
        apply(.date(calendarHelper.overrideDate(from: date)))
    }
}
