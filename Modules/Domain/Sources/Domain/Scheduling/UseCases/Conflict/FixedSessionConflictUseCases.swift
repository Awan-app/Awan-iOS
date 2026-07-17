import Foundation

public protocol KeepFixedOverAllocationUseCase: Sendable {
    func execute(_ request: FixedOverAllocationRequest) async throws -> ScheduleOperationResult
}

public struct DefaultKeepFixedOverAllocationUseCase: KeepFixedOverAllocationUseCase {
    private let reconciler: any TaskScheduleReconciling

    public init(reconciler: any TaskScheduleReconciling) {
        self.reconciler = reconciler
    }

    public func execute(
        _ request: FixedOverAllocationRequest
    ) async throws -> ScheduleOperationResult {
        try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: request.taskID,
                pendingZoneChange: request.pendingZoneChange,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone,
                ignoresFixedOverAllocation: true
            )
        )
    }
}

public protocol TrimFixedOverAllocationUseCase: Sendable {
    func execute(_ request: FixedOverAllocationRequest) async throws -> ScheduleOperationResult
}

public struct DefaultTrimFixedOverAllocationUseCase: TrimFixedOverAllocationUseCase {
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let reconciler: any TaskScheduleReconciling

    public init(
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        reconciler: any TaskScheduleReconciling
    ) {
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.reconciler = reconciler
    }

    public func execute(
        _ request: FixedOverAllocationRequest
    ) async throws -> ScheduleOperationResult {
        let tasks = try await taskRepository.fetchTasks()
        guard let task = tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
        let sessions = try await sessionRepository.fetchSessions()
        let completedMinutes = sessions
            .filter { $0.taskID == request.taskID && $0.status == .completed }
            .reduce(0) { $0 + $1.timeRange.durationMinutes }
        let targetFixedMinutes = max(0, task.duration.minutes - completedMinutes)
        let plannedFixedSessions = sessions
            .filter {
                $0.taskID == request.taskID
                    && $0.status == .planned
                    && $0.placement == .userFixed
            }
            .sorted { $0.timeRange.start > $1.timeRange.start }
        var excessMinutes = max(
            0,
            plannedFixedSessions.reduce(0) {
                $0 + $1.timeRange.durationMinutes
            } - targetFixedMinutes
        )

        for session in plannedFixedSessions where excessMinutes > 0 {
            let sessionMinutes = session.timeRange.durationMinutes
            if excessMinutes >= sessionMinutes {
                try await sessionRepository.deleteSession(id: session.id)
                excessMinutes -= sessionMinutes
            } else {
                let adjustedRange = try TimeRange(
                    start: session.timeRange.start,
                    end: session.timeRange.end.addingTimeInterval(
                        TimeInterval(-excessMinutes * 60)
                    )
                )
                try await sessionRepository.updateSession(
                    session.replacing(timeRange: adjustedRange)
                )
                excessMinutes = 0
            }
        }

        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: request.taskID,
                pendingZoneChange: request.pendingZoneChange,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}

public protocol KeepFixedSessionsOutsideZoneUseCase: Sendable {
    func execute(
        _ request: KeepFixedSessionsOutsideZoneRequest
    ) async throws -> ScheduleOperationResult
}

public struct DefaultKeepFixedSessionsOutsideZoneUseCase:
    KeepFixedSessionsOutsideZoneUseCase {
    private let reconciler: any TaskScheduleReconciling

    public init(reconciler: any TaskScheduleReconciling) {
        self.reconciler = reconciler
    }

    public func execute(
        _ request: KeepFixedSessionsOutsideZoneRequest
    ) async throws -> ScheduleOperationResult {
        try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: request.taskID,
                pendingZoneChange: nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone,
                ignoresFixedZoneMismatch: true
            )
        )
    }
}

public protocol MoveFixedSessionsIntoZoneUseCase: Sendable {
    func execute(
        _ request: MoveFixedSessionsIntoZoneRequest
    ) async throws -> ScheduleOperationResult
}

public struct DefaultMoveFixedSessionsIntoZoneUseCase: MoveFixedSessionsIntoZoneUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository
    private let zoneWindowResolver: any ZoneWindowResolving
    private let availabilityCalculator: any AvailabilityCalculating
    private let reconciler: any TaskScheduleReconciling

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository,
        zoneWindowResolver: any ZoneWindowResolving,
        availabilityCalculator: any AvailabilityCalculating,
        reconciler: any TaskScheduleReconciling
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
        self.zoneWindowResolver = zoneWindowResolver
        self.availabilityCalculator = availabilityCalculator
        self.reconciler = reconciler
    }

    public func execute(
        _ request: MoveFixedSessionsIntoZoneRequest
    ) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load()
        guard let zone = workspace.zones.first(where: { $0.id == request.zoneID }) else {
            throw SchedulingError.entityNotFound(id: request.zoneID)
        }
        let sessions = workspace.sessions
            .filter { request.sessionIDs.contains($0.id) }
            .sorted { $0.timeRange.start < $1.timeRange.start }
        var movedRanges: [TimeRange] = []
        let occupiedRanges = workspace.sessions
            .filter { !request.sessionIDs.contains($0.id) && $0.occupiesTime }
            .map(\.timeRange)

        for session in sessions {
            let window = try zoneWindowResolver.window(
                for: zone,
                on: session.timeRange.start,
                in: request.timeZone
            )
            let duration = session.timeRange.end.timeIntervalSince(session.timeRange.start)
            let freeRanges = try availabilityCalculator.freeRanges(
                inside: window,
                excluding: occupiedRanges + movedRanges,
                notBefore: nil
            )
            guard let freeRange = freeRanges.first(where: {
                $0.end.timeIntervalSince($0.start) >= duration
            }) else {
                throw SchedulingError.invalidScenarioState
            }
            let range = try TimeRange(
                start: freeRange.start,
                end: freeRange.start.addingTimeInterval(duration)
            )
            try await sessionRepository.updateSession(
                session.replacing(
                    zoneID: .some(request.zoneID),
                    timeRange: range,
                    placement: .userFixed
                )
            )
            movedRanges.append(range)
        }

        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: request.taskID,
                pendingZoneChange: nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone,
                ignoresFixedZoneMismatch: true
            )
        )
    }
}

public protocol RestoreTaskZoneUseCase: Sendable {
    func execute(_ request: RestoreTaskZoneRequest) async throws -> ScheduleOperationResult
}

public struct DefaultRestoreTaskZoneUseCase: RestoreTaskZoneUseCase {
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let reconciler: any TaskScheduleReconciling

    public init(
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        reconciler: any TaskScheduleReconciling
    ) {
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.reconciler = reconciler
    }

    public func execute(
        _ request: RestoreTaskZoneRequest
    ) async throws -> ScheduleOperationResult {
        let tasks = try await taskRepository.fetchTasks()
        guard let task = tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
        try await taskRepository.updateTask(
            AwanTask(
                id: task.id,
                title: task.title,
                goalID: task.goalID,
                zoneID: request.previousZoneID,
                duration: task.duration,
                isSplittable: task.isSplittable,
                dependencyIDs: task.dependencyIDs
            )
        )
        let sessions = try await sessionRepository.fetchSessions()
        for session in sessions where request.sessionIDs.contains(session.id) {
            try await sessionRepository.updateSession(
                session.replacing(zoneID: .some(request.previousZoneID))
            )
        }
        return try await reconciler.reconcile(
            TaskReconciliationRequest(
                taskID: request.taskID,
                pendingZoneChange: nil,
                selectedDay: request.selectedDay,
                timeZone: request.timeZone
            )
        )
    }
}
