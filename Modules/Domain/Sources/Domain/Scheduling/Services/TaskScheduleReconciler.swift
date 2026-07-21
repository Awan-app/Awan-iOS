import Foundation

public struct TaskReconciliationRequest: Hashable, Sendable {
    public let taskID: UUID
    public let pendingZoneChange: TaskZoneChange?
    public let selectedDay: Date
    public let timeZone: TimeZone
    public let ignoresFixedOverAllocation: Bool
    public let ignoresFixedZoneMismatch: Bool

    public init(
        taskID: UUID,
        pendingZoneChange: TaskZoneChange?,
        selectedDay: Date,
        timeZone: TimeZone,
        ignoresFixedOverAllocation: Bool = false,
        ignoresFixedZoneMismatch: Bool = false
    ) {
        self.taskID = taskID
        self.pendingZoneChange = pendingZoneChange
        self.selectedDay = selectedDay
        self.timeZone = timeZone
        self.ignoresFixedOverAllocation = ignoresFixedOverAllocation
        self.ignoresFixedZoneMismatch = ignoresFixedZoneMismatch
    }
}

public protocol TaskScheduleReconciling: Sendable {
    func reconcile(_ request: TaskReconciliationRequest) async throws -> ScheduleOperationResult
}

public struct DefaultTaskScheduleReconciler: TaskScheduleReconciling {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository
    private let engine: any ScheduleEngine
    private let zoneWindowResolver: any ZoneWindowResolving
    private let idGenerator: any UUIDGenerating

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository,
        engine: any ScheduleEngine,
        zoneWindowResolver: any ZoneWindowResolving,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
        self.engine = engine
        self.zoneWindowResolver = zoneWindowResolver
        self.idGenerator = idGenerator
    }

    public func reconcile(
        _ request: TaskReconciliationRequest
    ) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load(for: request.selectedDay)
        guard let task = workspace.tasks.first(where: { $0.id == request.taskID }) else {
            throw SchedulingError.entityNotFound(id: request.taskID)
        }

        let taskSessions = workspace.sessions.filter { $0.taskID == request.taskID }
        let completedSessions = taskSessions.filter { $0.status == .completed }
        let plannedFixedSessions = taskSessions.filter {
            $0.status == .planned && $0.blocking
        }
        let completedMinutes = completedSessions.reduce(0) {
            $0 + $1.timeRange.durationMinutes
        }
        let fixedMinutes = plannedFixedSessions.reduce(0) {
            $0 + $1.timeRange.durationMinutes
        }
        let protectedMinutes = completedMinutes + fixedMinutes

        if protectedMinutes > task.duration.minutes,
           !request.ignoresFixedOverAllocation {
            return ScheduleOperationResult(
                workspace: workspace,
                nudge: .fixedSessionOverAllocation(
                    taskID: request.taskID,
                    pendingZoneChange: request.pendingZoneChange,
                    sessionIDs: (completedSessions + plannedFixedSessions).map(\.id),
                    scheduledMinutes: protectedMinutes,
                    taskMinutes: task.duration.minutes,
                    canTrim: completedMinutes <= task.duration.minutes
                        && !plannedFixedSessions.isEmpty,
                    selectedDay: request.selectedDay,
                    timeZone: request.timeZone
                )
            )
        }

        if request.pendingZoneChange != nil,
           !request.ignoresFixedZoneMismatch,
           let zoneID = task.zoneID,
           let zone = workspace.zones.first(where: { $0.id == zoneID }) {
            let affectedSessionIDs = try plannedFixedSessions.compactMap { session in
                let window = try zoneWindowResolver.window(
                    for: zone,
                    on: session.timeRange.start,
                    in: request.timeZone
                )
                let isInsideZone = session.timeRange.start >= window.start
                    && session.timeRange.end <= window.end
                return isInsideZone ? nil : session.id
            }
            if !affectedSessionIDs.isEmpty {
                return ScheduleOperationResult(
                    workspace: workspace,
                    nudge: .fixedSessionsOutsideTaskZone(
                        taskID: request.taskID,
                        previousZoneID: request.pendingZoneChange?.previousZoneID,
                        zoneID: zoneID,
                        sessionIDs: affectedSessionIDs,
                        selectedDay: request.selectedDay,
                        timeZone: request.timeZone
                    )
                )
            }
        }

        guard task.zoneID != nil else {
            return ScheduleOperationResult(workspace: workspace, nudge: nil)
        }

        let schedulingTasks = try dependencyClosure(for: task, in: workspace.tasks)
        let unavailableDependencies = Set(task.dependencyIDs.filter { dependencyID in
            guard let dependency = workspace.tasks.first(where: { $0.id == dependencyID }) else {
                return true
            }
            let scheduledMinutes = workspace.sessions
                .filter { $0.taskID == dependencyID && $0.contributesScheduledWork }
                .reduce(0) { $0 + $1.timeRange.durationMinutes }
            return scheduledMinutes < dependency.duration.minutes
        })

        if !unavailableDependencies.isEmpty {
            let remainingMinutes = max(0, task.duration.minutes - protectedMinutes)
            return ScheduleOperationResult(
                workspace: workspace,
                nudge: .schedulingIssue(
                    SchedulingIssue(
                        taskID: request.taskID,
                        reason: .dependencyUnavailable(
                            dependencyIDs: unavailableDependencies
                        ),
                        requiredMinutes: remainingMinutes,
                        availableMinutes: 0,
                        resolutionCandidates: []
                    )
                )
            )
        }

        let result = try engine.makePlan(
            for: SchedulingSnapshot(
                planningDay: request.selectedDay,
                timeZone: request.timeZone,
                zones: workspace.zones,
                goals: workspace.goals,
                tasks: schedulingTasks,
                sessions: workspace.sessions
            )
        )
        for draft in result.todaySessionDrafts where draft.taskID == request.taskID {
            try await sessionRepository.addSession(makeSession(from: draft))
        }

        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(for: request.selectedDay),
            nudge: result.issues
                .first(where: { $0.taskID == request.taskID })
                .map(ScheduleNudge.schedulingIssue)
        )
    }

    private func dependencyClosure(
        for task: AwanTask,
        in tasks: [AwanTask]
    ) throws -> [AwanTask] {
        let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        var resultByID: [UUID: AwanTask] = [:]

        func include(_ current: AwanTask) throws {
            guard resultByID[current.id] == nil else { return }
            resultByID[current.id] = current
            for dependencyID in current.dependencyIDs {
                guard let dependency = tasksByID[dependencyID] else {
                    throw SchedulingError.missingDependency(
                        taskID: current.id,
                        dependencyID: dependencyID
                    )
                }
                try include(dependency)
            }
        }

        try include(task)
        return Array(resultByID.values)
    }

    private func makeSession(from draft: SessionDraft) -> Session {
        Session(
            id: idGenerator.makeUUID(),
            taskID: draft.taskID,
            zoneID: draft.zoneID,
            timeRange: draft.timeRange,
            blocking: false,
            status: .planned
        )
    }
}
