public protocol UpdateTaskUseCase: Sendable {
    func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult
}

public struct DefaultUpdateTaskUseCase: UpdateTaskUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let reconciler: any TaskScheduleReconciling

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        reconciler: any TaskScheduleReconciling
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.reconciler = reconciler
    }

    public func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult {
        let tasks = try await taskRepository.fetchTasks()
        guard let previousTask = tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
        let updatedTask = try AwanTask(
            id: previousTask.id,
            title: request.title,
            goalID: previousTask.goalID,
            zoneID: request.zoneID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            dependencyIDs: previousTask.dependencyIDs
        )
        try await taskRepository.updateTask(updatedTask)

        let requiresReconciliation = previousTask.duration != updatedTask.duration
            || previousTask.zoneID != updatedTask.zoneID
        guard requiresReconciliation else {
            return ScheduleOperationResult(
                workspace: try await workspaceProvider.load(),
                nudge: nil
            )
        }

        let taskSessions = try await sessionRepository.fetchSessions()
            .filter { $0.taskID == updatedTask.id }
        for session in taskSessions where session.status == .planned {
            switch session.placement {
            case .engineManaged:
                try await sessionRepository.deleteSession(id: session.id)
            case .userFixed where previousTask.zoneID != updatedTask.zoneID:
                try await sessionRepository.updateSession(
                    session.replacing(zoneID: .some(updatedTask.zoneID))
                )
            case .userFixed:
                break
            }
        }

        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: updatedTask.id,
                pendingZoneChange: previousTask.zoneID == updatedTask.zoneID
                    ? nil
                    : TaskZoneChange(previousZoneID: previousTask.zoneID),
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}
