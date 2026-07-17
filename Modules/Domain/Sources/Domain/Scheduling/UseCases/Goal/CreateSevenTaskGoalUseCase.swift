import Foundation

public protocol CreateSevenTaskGoalUseCase: Sendable {
    func execute(
        _ request: CreateSevenTaskGoalRequest
    ) async throws -> ScheduleOperationResult
}

public struct DefaultCreateSevenTaskGoalUseCase: CreateSevenTaskGoalUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let goalRepository: any GoalRepository
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let engine: any ScheduleEngine
    private let idGenerator: any UUIDGenerating

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        goalRepository: any GoalRepository,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        engine: any ScheduleEngine,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.workspaceProvider = workspaceProvider
        self.goalRepository = goalRepository
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.engine = engine
        self.idGenerator = idGenerator
    }

    public func execute(
        _ request: CreateSevenTaskGoalRequest
    ) async throws -> ScheduleOperationResult {
        guard let deadline = date(
            byAddingDays: 6,
            to: request.startDay,
            in: request.timeZone
        ) else {
            throw SchedulingError.invalidTimeRange
        }
        let goal = Goal(
            id: idGenerator.makeUUID(),
            name: request.name,
            deadline: deadline
        )
        var tasks: [AwanTask] = []
        for index in 0..<7 {
            let dependencyIDs = tasks.last.map { Set([$0.id]) } ?? []
            tasks.append(
                try AwanTask(
                    id: idGenerator.makeUUID(),
                    title: "\(request.name) · Step \(index + 1)",
                    goalID: goal.id,
                    zoneID: request.zoneID,
                    duration: TaskDuration(minutes: request.taskDurationMinutes),
                    isSplittable: true,
                    dependencyIDs: dependencyIDs
                )
            )
        }

        try await goalRepository.addGoal(goal)
        for task in tasks {
            try await taskRepository.addTask(task)
        }

        var workspace = try await workspaceProvider.load()
        var firstIssue: SchedulingIssue?
        for index in tasks.indices {
            guard let planningDay = date(
                byAddingDays: index,
                to: request.startDay,
                in: request.timeZone
            ) else {
                continue
            }
            let result = try engine.makePlan(
                for: SchedulingSnapshot(
                    planningDay: planningDay,
                    timeZone: request.timeZone,
                    zones: workspace.zones,
                    goals: workspace.goals,
                    tasks: Array(tasks.prefix(index + 1)),
                    sessions: workspace.sessions
                )
            )
            if let draft = result.todaySessionDrafts.first(
                where: { $0.taskID == tasks[index].id }
            ) {
                try await sessionRepository.addSession(makeSession(from: draft))
                workspace = try await workspaceProvider.load()
            } else if firstIssue == nil {
                firstIssue = result.issues.first(where: { $0.taskID == tasks[index].id })
                break
            }
        }

        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: firstIssue.map(ScheduleNudge.schedulingIssue)
        )
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

    private func date(
        byAddingDays days: Int,
        to date: Date,
        in timeZone: TimeZone
    ) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .day, value: days, to: date)
    }
}
