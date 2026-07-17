public protocol ResetScheduleSimulationUseCase: Sendable {
    func execute() async throws -> ScheduleWorkspace
}

public struct DefaultResetScheduleSimulationUseCase: ResetScheduleSimulationUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let zoneRepository: any ZoneRepository
    private let taskRepository: any TaskRepository
    private let goalRepository: any GoalRepository
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        zoneRepository: any ZoneRepository,
        taskRepository: any TaskRepository,
        goalRepository: any GoalRepository,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.zoneRepository = zoneRepository
        self.taskRepository = taskRepository
        self.goalRepository = goalRepository
        self.sessionRepository = sessionRepository
    }

    public func execute() async throws -> ScheduleWorkspace {
        try await sessionRepository.deleteAllSessions()
        try await taskRepository.deleteAllTasks()
        try await goalRepository.deleteAllGoals()
        try await zoneRepository.resetZones()
        return try await workspaceProvider.load()
    }
}
