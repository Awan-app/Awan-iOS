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
    @ObservationIgnored private var tasks: [AwanTask] = []
    @ObservationIgnored var sessions: [Session] = []
    @ObservationIgnored private var zones: [Zone] = []
    @ObservationIgnored private var profile: UserProfile?

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
            guard state.timelineItems.contains(where: { $0.id == id }) else { return }
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
            state.errorMessage = nil
        }
    }

    private func load() {
        loadTask?.cancel()
        let selectedDay = state.selectedDay
        state.status = .loading
        state.errorMessage = nil

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

                self.tasks = loaded.0
                self.sessions = loaded.1
                self.zones = loaded.2
                self.profile = loaded.3
                applyContent()
                state.status = .ready
            } catch is CancellationError {
                return
            } catch {
                guard state.selectedDay == selectedDay else { return }
                state.status = .failure
                state.errorMessage = error.localizedDescription
            }
        }
    }

    func applyContent() {
        guard let profile else { return }
        let content = mapper.map(
            tasks: tasks,
            sessions: sessions,
            zones: zones,
            profile: profile,
            selectedDay: state.selectedDay
        )
        state.displayName = content.displayName
        state.streakCount = content.streakCount
        state.rewardPoints = content.rewardPoints
        state.taskCount = content.taskCount
        state.scheduledMinutes = content.scheduledMinutes
        state.completedSessionCount = content.completedSessionCount
        state.totalSessionCount = content.totalSessionCount
        state.taskAllocations = content.taskAllocations
        state.timelineWindow = content.timelineWindow
        state.timelineZones = content.timelineZones
        state.timelineItems = content.timelineItems
        if let selectedID = state.selectedSessionID,
           !content.timelineItems.contains(where: { $0.id == selectedID }) {
            state.selectedSessionID = nil
        }
    }
}
