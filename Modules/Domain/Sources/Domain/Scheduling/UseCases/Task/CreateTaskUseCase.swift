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

    public func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(for: request.selectedDay)
        let selection = try resolveSelection(for: request, from: workspace.zones)
        let task = try AwanTask(
            id: idGenerator.makeUUID(),
            title: request.title,
            description: request.description,
            status: .pending,
            goalID: nil,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: request.estimatedPoints,
            dependencyIDs: [],
            category: selection.category
        )
        _ = try await taskRepository.addTask(
            task,
            sessionZoneID: selection.sessionZoneID,
            startsAt: request.startsAt,
            durationMinutes: request.durationMinutes,
            timeZoneID: request.timeZone.identifier
        )
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(for: request.selectedDay),
            nudge: nil
        )
    }

    private func resolveSelection(
        for request: CreateTaskRequest,
        from zones: [Zone]
    ) throws -> (category: TaskCategory?, sessionZoneID: UUID?) {
        if let zoneID = request.zoneID {
            guard let zone = zones.first(where: { $0.id == zoneID }) else {
                throw SchedulingError.entityNotFound(id: zoneID)
            }
            return (zone.category, zone.id)
        }

        guard let categoryID = request.categoryID else {
            return (nil, nil)
        }

        guard let zone = zones.first(where: { $0.category?.id == categoryID })
        else {
            throw SchedulingError.entityNotFound(id: categoryID)
        }
        return (zone.category, zone.id)
    }
}
