import Foundation

public protocol CreateTaskUseCase: Sendable {
    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult
}

public struct DefaultCreateTaskUseCase: CreateTaskUseCase {
    private let taskRepository: any TaskRepository
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let idGenerator: any UUIDGenerating

    public init(
        taskRepository: any TaskRepository,
        workspaceProvider: any ScheduleWorkspaceProviding,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.taskRepository = taskRepository
        self.workspaceProvider = workspaceProvider
        self.idGenerator = idGenerator
    }

    public func execute(
        _ request: CreateTaskRequest
    ) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(
            for: request.selectedDay
        )

        let zone = workspace.zones.first {
            $0.category?.id == request.categoryID
        }

        let task = try AwanTask(
            id: idGenerator.makeUUID(),
            title: request.title,
            description: request.description,
            status: .pending,
            goalID: nil,
            duration: TaskDuration(
                minutes: request.durationMinutes
            ),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: request.estimatedPoints,
            dependencyIDs: [],
            category: zone?.category
        )

        _ = try await taskRepository.addTask(
            task,
            categoryID: request.categoryID,
            sessionZoneID: zone?.id,
            startsAt: request.startsAt,
            durationMinutes: request.durationMinutes,
            timeZoneID: request.timeZone.identifier
        )

        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(
                for: request.selectedDay
            ),
            nudge: nil
        )
    }
}
