import Foundation

public protocol ResetScheduleSimulationUseCase: Sendable {
    func execute(on selectedDay: Date) async throws -> ScheduleWorkspace
}

public struct ResetScheduleSimulationUseCaseImpl: ResetScheduleSimulationUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository
    private let goalRepository: any GoalRepository
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository,
        goalRepository: any GoalRepository,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
        self.goalRepository = goalRepository
        self.sessionRepository = sessionRepository
    }

    public func execute(on selectedDay: Date) async throws -> ScheduleWorkspace {
        try await sessionRepository.deleteAllSessions()
        try await taskRepository.deleteAllTasks()
        try await goalRepository.deleteAllGoals()
        return try await workspaceProvider.load(for: selectedDay)
    }
}
