import Foundation

public protocol ApplyScheduleCandidateUseCase: Sendable {
    func execute(_ candidate: ResolutionCandidate) async throws -> ScheduleOperationResult
}

public struct DefaultApplyScheduleCandidateUseCase: ApplyScheduleCandidateUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository
    private let idGenerator: any UUIDGenerating

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
        self.idGenerator = idGenerator
    }

    public func execute(
        _ candidate: ResolutionCandidate
    ) async throws -> ScheduleOperationResult {
        for draft in candidate.sessionDrafts {
            try await sessionRepository.addSession(
                Session(
                    id: idGenerator.makeUUID(),
                    taskID: draft.taskID,
                    zoneID: draft.zoneID,
                    timeRange: draft.timeRange,
                    blocking: false,
                    status: .planned
                )
            )
        }
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol SeparateOverlappingSessionsUseCase: Sendable {
    func execute(_ request: OverlappingSessionsRequest) async throws -> ScheduleOperationResult
}

public struct DefaultSeparateOverlappingSessionsUseCase: SeparateOverlappingSessionsUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
    }

    public func execute(
        _ request: OverlappingSessionsRequest
    ) async throws -> ScheduleOperationResult {
        let sessions = try await sessionRepository.fetchSessions()
        guard let first = sessions.first(where: { $0.id == request.firstSessionID }),
              let second = sessions.first(where: { $0.id == request.secondSessionID }) else {
            throw SchedulingError.entityNotFound(id: request.firstSessionID)
        }
        let duration = first.timeRange.end.timeIntervalSince(first.timeRange.start)
        let range = try TimeRange(
            start: second.timeRange.start.addingTimeInterval(-duration),
            end: second.timeRange.start
        )
        try await sessionRepository.updateSession(
            first.replacing(timeRange: range, blocking: true)
        )
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol MoveOverlappingSessionUseCase: Sendable {
    func execute(_ request: OverlappingSessionsRequest) async throws -> ScheduleOperationResult
}

public struct DefaultMoveOverlappingSessionUseCase: MoveOverlappingSessionUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
    }

    public func execute(
        _ request: OverlappingSessionsRequest
    ) async throws -> ScheduleOperationResult {
        let sessions = try await sessionRepository.fetchSessions()
        guard let first = sessions.first(where: { $0.id == request.firstSessionID }),
              let second = sessions.first(where: { $0.id == request.secondSessionID }) else {
            throw SchedulingError.entityNotFound(id: request.secondSessionID)
        }
        let duration = second.timeRange.end.timeIntervalSince(second.timeRange.start)
        let range = try TimeRange(
            start: first.timeRange.end,
            end: first.timeRange.end.addingTimeInterval(duration)
        )
        try await sessionRepository.updateSession(
            second.replacing(timeRange: range, blocking: true)
        )
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol ShiftGoalDependencyChainUseCase: Sendable {
    func execute(
        _ request: ShiftGoalDependencyChainRequest
    ) async throws -> ScheduleOperationResult
}

public struct DefaultShiftGoalDependencyChainUseCase: ShiftGoalDependencyChainUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository
    private let goalRepository: any GoalRepository
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository,
        goalRepository: any GoalRepository,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
        self.goalRepository = goalRepository
        self.sessionRepository = sessionRepository
    }

    public func execute(
        _ request: ShiftGoalDependencyChainRequest
    ) async throws -> ScheduleOperationResult {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = request.timeZone
        let tasks = try await taskRepository.fetchTasks()
            .filter { $0.goalID == request.goalID }
        let taskIDs = Set(tasks.map(\.id))
        let sessions = try await sessionRepository.fetchSessions()
            .filter { taskIDs.contains($0.taskID) }

        for session in sessions {
            guard let start = calendar.date(
                byAdding: .day,
                value: 1,
                to: session.timeRange.start
            ), let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: session.timeRange.end
            ) else {
                throw SchedulingError.invalidTimeRange
            }
            try await sessionRepository.updateSession(
                session.replacing(
                    timeRange: try TimeRange(start: start, end: end),
                    blocking: false,
                    status: .planned
                )
            )
        }

        if let goal = try await goalRepository.fetchGoals()
            .first(where: { $0.id == request.goalID }) {
            guard let deadline = calendar.date(
                byAdding: .day,
                value: 1,
                to: goal.deadline
            ) else {
                throw SchedulingError.invalidTimeRange
            }
            try await goalRepository.updateGoal(
                Goal(
                    id: goal.id,
                    name: goal.name,
                    description: goal.description,
                    status: goal.status,
                    deadline: deadline,
                    createdAt: goal.createdAt
                )
            )
        }
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol StackDependentTasksUseCase: Sendable {
    func execute(_ request: StackDependentTasksRequest) async throws -> ScheduleOperationResult
}

public struct DefaultStackDependentTasksUseCase: StackDependentTasksUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
    }

    public func execute(
        _ request: StackDependentTasksRequest
    ) async throws -> ScheduleOperationResult {
        let sessions = try await sessionRepository.fetchSessions()
        guard let missed = sessions.first(where: { $0.taskID == request.missedTaskID }),
              let successor = sessions.first(where: { $0.taskID == request.successorTaskID }) else {
            throw SchedulingError.entityNotFound(id: request.missedTaskID)
        }
        for session in [missed, successor] {
            try await sessionRepository.updateSession(
                session.replacing(
                    timeRange: successor.timeRange,
                    blocking: true,
                    status: .planned
                )
            )
        }
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol MakeTaskIndependentUseCase: Sendable {
    func execute(_ request: MakeTaskIndependentRequest) async throws -> ScheduleOperationResult
}

public struct DefaultMakeTaskIndependentUseCase: MakeTaskIndependentUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let taskRepository: any TaskRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        taskRepository: any TaskRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.taskRepository = taskRepository
    }

    public func execute(
        _ request: MakeTaskIndependentRequest
    ) async throws -> ScheduleOperationResult {
        let tasks = try await taskRepository.fetchTasks()
        guard let task = tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }
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
                dependencyIDs: task.dependencyIDs.subtracting([request.dependencyID])
            )
        )
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}
