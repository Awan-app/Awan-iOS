import Foundation

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
            description: previousTask.description,
            status: previousTask.status,
            goalID: previousTask.goalID,
            zoneID: request.zoneID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: previousTask.mandatory,
            estimatedPoints: previousTask.estimatedPoints,
            dependencyIDs: previousTask.dependencyIDs
        )
        try await taskRepository.updateTask(updatedTask)

        let plannedSessions = try await sessionRepository.fetchSessions()
            .filter { $0.taskID == updatedTask.id && $0.status == .planned }
        let blockingChanged = plannedSessions.contains {
            $0.blocking != request.blocking
        }
        let zoneChanged = previousTask.zoneID != updatedTask.zoneID
        let durationIncrease = max(
            0,
            updatedTask.duration.minutes - previousTask.duration.minutes
        )
        let sessionToExtendID = plannedSessions
            .sorted { $0.timeRange.start < $1.timeRange.start }
            .first?
            .id
        let requiresReconciliation = previousTask.duration != updatedTask.duration
            || zoneChanged
            || blockingChanged
        guard requiresReconciliation else {
            return ScheduleOperationResult(
                workspace: try await workspaceProvider.load(for: request.selectedDay),
                nudge: nil
            )
        }

        for session in plannedSessions {
            if request.blocking {
                let extendedRange: TimeRange?
                if session.id == sessionToExtendID, durationIncrease > 0 {
                    extendedRange = try TimeRange(
                        start: session.timeRange.start,
                        end: session.timeRange.end.addingTimeInterval(
                            TimeInterval(durationIncrease * 60)
                        )
                    )
                } else {
                    extendedRange = nil
                }
                try await sessionRepository.updateSession(
                    session.replacing(
                        zoneID: zoneChanged ? .some(updatedTask.zoneID) : nil,
                        timeRange: extendedRange,
                        blocking: true
                    )
                )
            } else {
                try await sessionRepository.deleteSession(id: session.id)
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
