import Combine
import Domain
import Foundation
@testable import Data

struct LocalTaskRepositoryStub: TaskRepository {
    let dataSource: any LocalTaskDataSource
    let sessionDataSource: any LocalSessionDataSource
    func fetchTasks() async throws -> [AwanTask] { try await dataSource.fetchTasks() }
    func fetchInboxTasks() async throws -> [AwanTask] { try await dataSource.fetchTasks() }
    func observeTasks() -> AnyPublisher<[AwanTask], Error> { dataSource.observeTasks() }
    func observeInboxTasks() -> AnyPublisher<[AwanTask], Error> { dataSource.observeTasks() }
    func addTask(
        _ task: AwanTask,
        sessionZoneID: UUID?,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) async throws -> (task: AwanTask, sessions: [Session]) {
        try await dataSource.addTask(task)
        return (task, [])
    }
    func updateTask(_ task: AwanTask) async throws { try await dataSource.updateTask(task) }
    func deleteTask(id: UUID) async throws {
        try await sessionDataSource.deleteSessions(taskID: id)
        try await dataSource.deleteTask(id: id)
    }
    func deleteAllTasks() async throws { try await dataSource.deleteAllTasks() }
    func addDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await dataSource.addDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    func removeDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await dataSource.removeDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    func fetchDependencies(taskID: UUID) async throws -> [AwanTask] {
        try await dataSource.fetchDependencies(taskID: taskID)
    }
    func fetchDependents(taskID: UUID) async throws -> [AwanTask] {
        try await dataSource.fetchDependents(taskID: taskID)
    }
}

struct LocalSessionRepositoryStub: SessionRepository {
    let dataSource: any LocalSessionDataSource

    func fetchSessions() async throws -> [Session] { try await dataSource.fetchSessions() }
    func addSession(_ session: Session) async throws { try await dataSource.addSession(session) }
    func updateSession(_ session: Session) async throws {
        try await dataSource.updateSession(session)
    }
    func deleteSession(id: UUID) async throws { try await dataSource.deleteSession(id: id) }
    func deleteSessions(taskID: UUID) async throws {
        try await dataSource.deleteSessions(taskID: taskID)
    }
    func deleteAllSessions() async throws { try await dataSource.deleteAllSessions() }
}

/// Keeps the local scheduling integration lab exercising the retained engine and
/// reconciler without routing production task creation through them.
struct LegacyLocalCreateTaskUseCase: CreateTaskUseCase {
    let workspaceProvider: any ScheduleWorkspaceProviding
    let taskRepository: any TaskRepository
    let reconciler: any TaskScheduleReconciling

    func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(for: request.selectedDay)
        let selectedZone = request.zoneID.flatMap { zoneID in
            workspace.zones.first { $0.id == zoneID }
        } ?? request.categoryID.flatMap { categoryID in
            workspace.zones.first { $0.category?.id == categoryID }
        }
        let selectedCategory = selectedZone?.category
        let task = try AwanTask(
            id: UUID(),
            title: request.title,
            description: request.description,
            duration: TaskDuration(minutes: request.durationMinutes),
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: request.estimatedPoints,
            category: selectedCategory
        )
        let (confirmed, _) = try await taskRepository.addTask(
            task,
            sessionZoneID: selectedZone?.id,
            startsAt: request.startsAt,
            durationMinutes: request.durationMinutes,
            timeZoneID: request.timeZone.identifier
        )
        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: confirmed.id,
                pendingZoneChange: nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}

/// Test-only adapter for legacy conflict scenarios. Production updates are
/// backend-authoritative and use `DefaultUpdateTaskUseCase`.
struct LegacyLocalUpdateTaskUseCase: UpdateTaskUseCase {
    let workspaceProvider: any ScheduleWorkspaceProviding
    let taskRepository: any TaskRepository
    let sessionRepository: any SessionRepository
    let reconciler: any TaskScheduleReconciling

    func execute(_ request: UpdateTaskRequest) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(for: request.selectedDay)
        guard let previousTask = workspace.tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
        let previousZone = workspace.zones
            .filter { $0.category?.id == previousTask.category?.id }
            .min { $0.startTime < $1.startTime }
        let selectedZone = request.zoneID.flatMap { zoneID in
            workspace.zones.first { $0.id == zoneID }
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
            category: selectedZone?.category
        )
        try await taskRepository.updateTask(updatedTask)

        let plannedSessions = try await sessionRepository.fetchSessions()
            .filter { $0.taskID == updatedTask.id && $0.status == .planned }
        let blockingChanged = plannedSessions.contains { $0.blocking != request.blocking }
        let categoryChanged = previousTask.category?.id != updatedTask.category?.id
        let durationIncrease = max(
            0,
            updatedTask.duration.minutes - previousTask.duration.minutes
        )
        let sessionToExtendID = plannedSessions
            .sorted { $0.timeRange.start < $1.timeRange.start }
            .first?
            .id
        let requiresReconciliation = previousTask.duration != updatedTask.duration
            || categoryChanged
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
                    Session(
                        id: session.id,
                        taskID: session.taskID,
                        zoneID: categoryChanged ? selectedZone?.id : session.zoneID,
                        timeRange: extendedRange ?? session.timeRange,
                        blocking: true,
                        status: session.status
                    )
                )
            } else {
                try await sessionRepository.deleteSession(id: session.id)
            }
        }

        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: updatedTask.id,
                pendingZoneChange: categoryChanged
                    ? TaskZoneChange(previousZoneID: previousZone?.id)
                    : nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}
