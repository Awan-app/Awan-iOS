import Foundation

public protocol UpdateTaskUseCase: Sendable {
    func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult
}

public struct DefaultUpdateTaskUseCase: UpdateTaskUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
    }

    public func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(for: request.selectedDay)
        guard let previousTask = workspace.tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
        let selectedCategory: TaskCategory?
        if let zoneID = request.zoneID {
            guard let zone = workspace.zones.first(where: { $0.id == zoneID }) else {
                throw SchedulingError.entityNotFound(id: zoneID)
            }
            selectedCategory = zone.category
        } else {
            selectedCategory = nil
        }
        let updatedTask = try AwanTask(
            id: previousTask.id,
            title: request.title,
            description: previousTask.description,
            status: previousTask.status,
            goalID: previousTask.goalID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: previousTask.mandatory,
            estimatedPoints: previousTask.estimatedPoints,
            dependencyIDs: previousTask.dependencyIDs,
            category: selectedCategory
        )
        try await taskRepository.updateTask(updatedTask)
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(for: request.selectedDay),
            nudge: nil
        )
    }
}
