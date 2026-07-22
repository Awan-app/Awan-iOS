import Foundation

public protocol DeleteTaskUseCase: Sendable {
    func execute(taskID: UUID, selectedDay: Date) async throws -> ScheduleWorkspace
}

public struct DefaultDeleteTaskUseCase: DeleteTaskUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
        _ = sessionRepository
    }

    public func execute(taskID: UUID, selectedDay: Date) async throws -> ScheduleWorkspace {
        try await taskRepository.deleteTask(id: taskID)
        return try await workspaceProvider.load(for: selectedDay)
    }
}
