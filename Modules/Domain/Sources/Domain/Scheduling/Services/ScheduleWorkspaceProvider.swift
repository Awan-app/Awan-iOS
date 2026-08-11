import Foundation

public protocol ScheduleWorkspaceProviding: Sendable {
    func load(for date: Date) async throws -> ScheduleWorkspace
}

public struct DefaultScheduleWorkspaceProvider: ScheduleWorkspaceProviding {
    private let zoneRepository: any ZoneRepository
    private let goalRepository: any GoalRepository
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository

    public init(
        zoneRepository: any ZoneRepository,
        goalRepository: any GoalRepository,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository
    ) {
        self.zoneRepository = zoneRepository
        self.goalRepository = goalRepository
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
    }

    public func load(for date: Date) async throws -> ScheduleWorkspace {
        _ = try? await taskRepository.fetchTasks(for: date)

        let zones = (try? await zoneRepository.fetchZones(for: date)) ?? []
        let goals = (try? await goalRepository.fetchGoals()) ?? []
        let tasks = (try? await taskRepository.fetchTasks()) ?? []
        let sessions = (try? await sessionRepository.fetchSessions()) ?? []

        return ScheduleWorkspace(
            zones: zones.sorted { $0.startTime < $1.startTime },
            goals: goals,
            tasks: tasks,
            sessions: sessions
        )
    }
}
