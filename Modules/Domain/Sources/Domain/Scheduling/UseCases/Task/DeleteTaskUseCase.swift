import Foundation

public protocol DeleteTaskUseCase: Sendable {
    func execute(taskID: UUID) async throws -> ScheduleWorkspace
}

public struct DefaultDeleteTaskUseCase: DeleteTaskUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
    }

    public func execute(taskID: UUID) async throws -> ScheduleWorkspace {
        let tasks = try await taskRepository.fetchTasks()
        for task in tasks where task.dependencyIDs.contains(taskID) {
            try await taskRepository.updateTask(
                AwanTask(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    status: task.status,
                    goalID: task.goalID,
                    zoneID: task.zoneID,
                    duration: task.duration,
                    isSplittable: task.isSplittable,
                    mandatory: task.mandatory,
                    estimatedPoints: task.estimatedPoints,
                    dependencyIDs: task.dependencyIDs.subtracting([taskID])
                )
            )
        }
        try await sessionRepository.deleteSessions(taskID: taskID)
        try await taskRepository.deleteTask(id: taskID)
        return try await workspaceProvider.load()
    }
}
