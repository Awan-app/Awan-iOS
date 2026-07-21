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
        async let zones = zoneRepository.fetchZones(for: date)
        async let goals = goalRepository.fetchGoals()
        async let tasks = taskRepository.fetchTasks()
        async let sessions = sessionRepository.fetchSessions()

        return try await ScheduleWorkspace(
            zones: zones.sorted { $0.startTime < $1.startTime },
            goals: goals,
            tasks: tasks,
            sessions: sessions
        )
    }
}
