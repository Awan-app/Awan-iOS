import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class HomeViewModel {
    var state: HomeState

    @ObservationIgnored let useCases: HomeUseCases
    @ObservationIgnored private let mapper: HomeStateMapper
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    public init(
        useCases: HomeUseCases,
        selectedDay: Date = Date(),
        timeZone: TimeZone = .current
    ) {
        self.useCases = useCases
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
        }
    }

    private func load() {
        loadTask?.cancel()
        let selectedDay = state.selectedDay
        state.isLoading = true
        state.failure = nil

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                async let tasks = useCases.reads.tasks.execute()
                async let sessions = useCases.reads.sessions.execute()
                async let zones = useCases.reads.zones.execute(for: selectedDay)
                async let profile = useCases.reads.userProfile.execute()
                let loaded = try await (tasks, sessions, zones, profile)
                try Task.checkCancellation()
                guard state.selectedDay == selectedDay else { return }

                state.success = mapper.map(
                    tasks: loaded.0,
                    sessions: loaded.1,
                    zones: loaded.2,
                    profile: loaded.3,
                    selectedDay: selectedDay
                )
                state.isLoading = false
            } catch is CancellationError {
                return
            } catch {
                guard state.selectedDay == selectedDay else { return }
                state.isLoading = false
                state.failure = HomeFailureState(message: error.localizedDescription)
            }
        }
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
}
