import Foundation

public struct CreateManualTaskRequest: Hashable, Sendable {
    public let title: String
    public let description: String?
    public let durationMinutes: Int
    public let zoneID: UUID?
    public let isSplittable: Bool
    public let mandatory: Bool
    public let startsAt: Date?
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        title: String,
        description: String? = nil,
        durationMinutes: Int,
        zoneID: UUID? = nil,
        isSplittable: Bool = true,
        mandatory: Bool = true,
        startsAt: Date? = nil,
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.title = title
        self.description = description
        self.durationMinutes = durationMinutes
        self.zoneID = zoneID
        self.isSplittable = isSplittable
        self.mandatory = mandatory
        self.startsAt = startsAt
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public protocol CreateManualTaskUseCase: Sendable {
    func execute(_ request: CreateManualTaskRequest) async throws -> ScheduleOperationResult
}

public struct DefaultCreateManualTaskUseCase: CreateManualTaskUseCase {
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let reconciler: any TaskScheduleReconciling
    private let idGenerator: any UUIDGenerating

    public init(
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        reconciler: any TaskScheduleReconciling,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.reconciler = reconciler
        self.idGenerator = idGenerator
    }

    public func execute(_ request: CreateManualTaskRequest) async throws -> ScheduleOperationResult {
        let draftTask = try AwanTask(
            id: UUID(), // Temporary ID, will be replaced by server
            title: request.title,
            description: request.description,
            status: .pending,
            goalID: nil,
            zoneID: request.zoneID,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: 10,
            dependencyIDs: []
        )

        let (confirmedTask, _) = try await taskRepository.addManualTask(
            draftTask,
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
