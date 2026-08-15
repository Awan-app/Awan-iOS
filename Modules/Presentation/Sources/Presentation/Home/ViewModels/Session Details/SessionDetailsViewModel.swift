import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class SessionDetailsViewModel {
    private(set) var state: SessionDetailsState

    @ObservationIgnored private let useCases: SessionDetailsUseCases
    @ObservationIgnored private let helper: SessionDetailsDraftHelper
    @ObservationIgnored private let statusUIFactory: SessionDetailsStatusUIFactory

    public init(
        context: SessionDetailsContext,
        useCases: SessionDetailsUseCases
    ) {
        let helper = SessionDetailsDraftHelper()
        let statusUIFactory = SessionDetailsStatusUIFactory()
        let request = UpdateSessionScheduleRequest(
            sessionID: context.session.id,
            selectedDay: context.session.timeRange.start,
            start: context.session.timeRange.start,
            end: context.session.timeRange.end,
            timeZoneIdentifier: context.timeZoneIdentifier
        )
        let validation = useCases.updateSchedule.validate(request)
        let durationMinutes = helper.durationMinutes(for: validation)
        self.useCases = useCases
        self.helper = helper
        self.statusUIFactory = statusUIFactory
        state = SessionDetailsState(
            task: context.task,
            color: context.color,
            timeZoneIdentifier: context.timeZoneIdentifier,
            originalSession: context.session,
            session: context.session,
            selectedDay: context.session.timeRange.start,
            draftStart: context.session.timeRange.start,
            draftEnd: context.session.timeRange.end,
            durationMinutes: durationMinutes,
            selectedDurationMinutes: helper.selectedPreset(
                for: durationMinutes
            ),
            statusUIModel: statusUIFactory.make(session: context.session),
            lockLabel: helper.lockLabel(isLocked: context.session.blocking),
            validationMessage: helper.validationMessage(for: validation),
            isDirty: false
        )
    }

    func send(_ action: SessionDetailsAction) {
        switch action {
        case .refreshStatus:
            state.statusUIModel = statusUIFactory.make(session: state.session)
        case let .setDay(day):
            setDay(day)
        case let .setStartTime(time):
            setStartTime(time)
        case let .setEndTime(time):
            setEndTime(time)
        case let .adjustStart(minutes):
            adjustStart(by: minutes)
        case let .adjustEnd(minutes):
            adjustEnd(by: minutes)
        case let .selectDuration(minutes):
            selectDuration(minutes)
        case .save:
            save()
        case .toggleLock:
            toggleLock()
        case .requestDelete:
            guard !state.isBusy else { return }
            state.confirmation = .delete
        case .confirmDelete:
            deleteSession()
        case .attemptDismiss:
            attemptDismiss()
        case .discardAndDismiss:
            state.confirmation = nil
            state.shouldDismiss = true
        case .cancelConfirmation:
            state.confirmation = nil
        case .dismissError:
            state.errorMessage = nil
        }
    }

    private func setDay(_ day: Date) {
        guard !state.isBusy,
              let start = helper.date(
                  on: day,
                  withTimeFrom: state.draftStart,
                  timeZoneIdentifier: state.timeZoneIdentifier
              ),
              let end = helper.date(
                  on: day,
                  withTimeFrom: state.draftEnd,
                  timeZoneIdentifier: state.timeZoneIdentifier
              ) else {
            return
        }
        state.selectedDay = day
        state.draftStart = start
        state.draftEnd = end
        refreshDraftState()
    }

    private func setStartTime(_ time: Date) {
        guard !state.isBusy,
              let start = helper.date(
                  on: state.selectedDay,
                  withTimeFrom: time,
                  timeZoneIdentifier: state.timeZoneIdentifier
              ) else {
            return
        }
        state.draftStart = start
        refreshDraftState()
    }

    private func setEndTime(_ time: Date) {
        guard !state.isBusy,
              let end = helper.date(
                  on: state.selectedDay,
                  withTimeFrom: time,
                  timeZoneIdentifier: state.timeZoneIdentifier
              ) else {
            return
        }
        state.draftEnd = end
        refreshDraftState()
    }

    private func adjustStart(by minutes: Int) {
        guard !state.isBusy,
              let start = helper.adjusting(state.draftStart, byMinutes: minutes) else {
            return
        }
        state.draftStart = start
        refreshDraftState()
    }

    private func adjustEnd(by minutes: Int) {
        guard !state.isBusy,
              let end = helper.adjusting(state.draftEnd, byMinutes: minutes) else {
            return
        }
        state.draftEnd = end
        refreshDraftState()
    }

    private func selectDuration(_ minutes: Int) {
        guard !state.isBusy,
              let end = helper.end(
                  start: state.draftStart,
                  durationMinutes: minutes
              ) else {
            return
        }
        state.draftEnd = end
        refreshDraftState()
    }

    private func refreshDraftState() {
        let validation = useCases.updateSchedule.validate(scheduleRequest)
        state.durationMinutes = helper.durationMinutes(for: validation)
        state.selectedDurationMinutes = helper.selectedPreset(
            for: state.durationMinutes
        )
        state.validationMessage = helper.validationMessage(for: validation)
        state.isDirty = helper.isDirty(
            original: state.originalSession.timeRange,
            draftStart: state.draftStart,
            draftEnd: state.draftEnd
        )
    }

    private func save() {
        guard state.canSave else { return }
        let request = scheduleRequest
        state.isSaving = true
        state.errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let session = try await useCases.updateSchedule.execute(request)
                state.session = session
                state.isSaving = false
                state.shouldDismiss = true
            } catch is CancellationError {
                state.isSaving = false
            } catch {
                state.isSaving = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func toggleLock() {
        guard !state.isBusy else { return }
        let shouldLock = !state.session.blocking
        state.isLocking = true
        state.errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                state.session = try await useCases.setLock.execute(
                    sessionID: state.session.id,
                    isLocked: shouldLock
                )
                state.statusUIModel = statusUIFactory.make(
                    session: state.session
                )
                state.lockLabel = helper.lockLabel(
                    isLocked: state.session.blocking
                )
                state.isLocking = false
            } catch is CancellationError {
                state.isLocking = false
            } catch {
                state.isLocking = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func deleteSession() {
        guard !state.isBusy else { return }
        state.confirmation = nil
        state.isDeleting = true
        state.errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                try await useCases.delete.execute(sessionID: state.session.id)
                state.isDeleting = false
                state.shouldDismiss = true
            } catch is CancellationError {
                state.isDeleting = false
            } catch {
                state.isDeleting = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func attemptDismiss() {
        guard !state.isBusy else { return }
        if state.isDirty {
            state.confirmation = .discardChanges
        } else {
            state.shouldDismiss = true
        }
    }

    private var scheduleRequest: UpdateSessionScheduleRequest {
        UpdateSessionScheduleRequest(
            sessionID: state.session.id,
            selectedDay: state.selectedDay,
            start: state.draftStart,
            end: state.draftEnd,
            timeZoneIdentifier: state.timeZoneIdentifier
        )
    }

}
