import Combine
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class HomeViewModel {
    var state: HomeState

    @ObservationIgnored let useCases: HomeUseCases
    @ObservationIgnored private let mapper: HomeStateMapper
    @ObservationIgnored private let timeZone: TimeZone
    @ObservationIgnored private var loadCancellable: AnyCancellable?

    public init(
        useCases: HomeUseCases,
        selectedDay: Date = Date(),
        timeZone: TimeZone = .current
    ) {
        self.useCases = useCases
        self.timeZone = timeZone
        self.mapper = HomeStateMapper(fallbackTimeZone: timeZone)
        self.state = .initial(selectedDay: selectedDay)
    }

    func send(_ action: HomeAction) {
        switch action {
        case .appeared, .refresh:
            load()
        case let .selectDay(day):
            state.selectedDay = day
            state.selectedSessionID = nil
            load()
        case let .presentSession(id):
            guard state.success?.timelineItems.contains(where: { $0.id == id }) == true else {
                return
            }
            state.selectedSessionID = id
        case .dismissSession:
            state.selectedSessionID = nil
        case let .moveSession(sessionID, verticalPoints, hourHeight):
            moveSession(
                id: sessionID,
                verticalPoints: verticalPoints,
                hourHeight: hourHeight
            )
        case let .rescheduleSession(sessionID, start):
            rescheduleSession(id: sessionID, proposedStart: start)
        case let .setSessionLock(sessionID, isLocked):
            setSessionLock(id: sessionID, isLocked: isLocked)
        case let .setSessionCompletion(sessionID, isCompleted):
            setSessionCompletion(id: sessionID, isCompleted: isCompleted)
        case let .deleteSession(id):
            deleteSession(id: id)
        case .dismissError:
            state.failure = nil
        case .presentAddTask:
            state.isAddTaskPresented = true
        case .dismissAddTask:
            state.isAddTaskPresented = false
        case .dismissNudge:
            state.activeNudge = nil
        case let .createTask(title, description, durationMinutes, zoneID, isSplittable, mandatory, startsAt):
            createTask(
                title: title,
                description: description,
                durationMinutes: durationMinutes,
                zoneID: zoneID,
                isSplittable: isSplittable,
                mandatory: mandatory,
                startsAt: startsAt
            )
        }
    }

    private func load() {
        loadCancellable?.cancel()
        let selectedDay = state.selectedDay
        state.isLoading = true
        state.failure = nil

        loadCancellable = useCases.reads.observe(for: selectedDay)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self, state.selectedDay == selectedDay else { return }
                    state.isLoading = false
                    if case let .failure(error) = completion {
                        state.failure = HomeFailureState(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] workspace in
                    guard let self, state.selectedDay == selectedDay else { return }
                    state.isLoading = false
                    state.success = mapper.map(
                        tasks: workspace.tasks,
                        sessions: workspace.sessions,
                        zones: workspace.zones,
                        profile: workspace.profile,
                        selectedDay: selectedDay
                    )
                }
            )
    }

    func applyContent() {
        guard let success = state.success else { return }
        let updated = mapper.map(
            tasks: success.tasks,
            sessions: success.sessions,
            zones: success.zones,
            profile: success.profile,
            selectedDay: state.selectedDay
        )
        state.success = updated
        if let selectedID = state.selectedSessionID,
           !updated.timelineItems.contains(where: { $0.id == selectedID }) {
            state.selectedSessionID = nil
        }
    }

    private func createTask(
        title: String,
        description: String?,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        mandatory: Bool,
        startsAt: Date
    ) {
        state.isMutating = true
        state.failure = nil

        Task { [weak self] in
            guard let self else { return }
            defer { state.isMutating = false }
            do {
                let request = CreateManualTaskRequest(
                    title: title,
                    description: description,
                    durationMinutes: durationMinutes,
                    zoneID: zoneID,
                    isSplittable: isSplittable,
                    mandatory: mandatory,
                    startsAt: startsAt,
                    selectedDay: state.selectedDay,
                    timeZone: timeZone
                )
                let result = try await useCases.createManualTask.execute(request)
                if let nudge = result.nudge {
                    state.activeNudge = nudge
                }
                state.isAddTaskPresented = false
            } catch is CancellationError {
            } catch {
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
    }
}
