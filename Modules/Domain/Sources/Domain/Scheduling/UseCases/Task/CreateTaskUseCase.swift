public protocol CreateTaskUseCase: Sendable {
    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult
}

public struct DefaultCreateTaskUseCase: CreateTaskUseCase {
    private let taskRepository: any TaskRepository
    private let reconciler: any TaskScheduleReconciling
    private let idGenerator: any UUIDGenerating

    public init(
        taskRepository: any TaskRepository,
        reconciler: any TaskScheduleReconciling,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.taskRepository = taskRepository
        self.reconciler = reconciler
        self.idGenerator = idGenerator
    }

    public func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        let task = try AwanTask(
            id: idGenerator.makeUUID(),
            title: request.title,
            description: request.description,
            status: .pending,
            goalID: nil,
            zoneID: request.zoneID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: request.estimatedPoints,
            dependencyIDs: []
        )
        let (confirmedTask, _) = try await taskRepository.addTask(
            task,
            startsAt: request.startsAt,
            durationMinutes: request.durationMinutes,
            timeZoneID: request.timeZone.identifier
        )
        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: confirmedTask.id,
                pendingZoneChange: nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}
