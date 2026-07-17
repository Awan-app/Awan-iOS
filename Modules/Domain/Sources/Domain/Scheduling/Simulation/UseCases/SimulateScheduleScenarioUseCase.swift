import Foundation

public protocol SimulateScheduleScenarioUseCase: Sendable {
    func execute(
        _ scenario: ScheduleSimulationScenario,
        on selectedDay: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult
}

public struct DefaultSimulateScheduleScenarioUseCase: SimulateScheduleScenarioUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let zoneRepository: any ZoneRepository
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let engine: any ScheduleEngine
    private let createGoalUseCase: any CreateSevenTaskGoalUseCase
    private let resetUseCase: any ResetScheduleSimulationUseCase
    private let idGenerator: any UUIDGenerating

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        zoneRepository: any ZoneRepository,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        engine: any ScheduleEngine,
        createGoalUseCase: any CreateSevenTaskGoalUseCase,
        resetUseCase: any ResetScheduleSimulationUseCase,
        idGenerator: any UUIDGenerating = SystemUUIDGenerator()
    ) {
        self.workspaceProvider = workspaceProvider
        self.zoneRepository = zoneRepository
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.engine = engine
        self.createGoalUseCase = createGoalUseCase
        self.resetUseCase = resetUseCase
        self.idGenerator = idGenerator
    }

    public func execute(
        _ scenario: ScheduleSimulationScenario,
        on selectedDay: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        _ = try await resetUseCase.execute()
        switch scenario {
        case .overlap:
            return try await simulateOverlap(on: selectedDay, in: timeZone)
        case .zoneOverflow:
            return try await simulateOverflow(on: selectedDay, in: timeZone)
        case .missedDependencyChain:
            return try await simulateMissedChain(on: selectedDay, in: timeZone)
        case .zoneReconfiguration:
            return try await simulateZoneReconfiguration(on: selectedDay, in: timeZone)
        }
    }

    private func simulateOverlap(
        on day: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        let workZone = try await requiredWorkZone()
        let first = try demoTask(title: "Deep work", zoneID: workZone.id, minutes: 90)
        let second = try demoTask(title: "Team sync", zoneID: workZone.id, minutes: 90)
        try await taskRepository.addTask(first)
        try await taskRepository.addTask(second)

        let firstSession = Session(
            id: idGenerator.makeUUID(),
            taskID: first.id,
            zoneID: workZone.id,
            timeRange: try range(
                on: day,
                startHour: 10,
                startMinute: 0,
                minutes: 90,
                timeZone: timeZone
            ),
            placement: .userFixed,
            status: .planned
        )
        let secondSession = Session(
            id: idGenerator.makeUUID(),
            taskID: second.id,
            zoneID: workZone.id,
            timeRange: try range(
                on: day,
                startHour: 10,
                startMinute: 30,
                minutes: 90,
                timeZone: timeZone
            ),
            placement: .userFixed,
            status: .planned
        )
        try await sessionRepository.addSession(firstSession)
        try await sessionRepository.addSession(secondSession)

        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: .overlap(
                firstSessionID: firstSession.id,
                secondSessionID: secondSession.id
            )
        )
    }

    private func simulateOverflow(
        on day: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        let workZone = try await requiredWorkZone()
        let filler = try demoTask(title: "Launch sprint", zoneID: workZone.id, minutes: 450)
        let overflow = try AwanTask(
            id: idGenerator.makeUUID(),
            title: "Prepare presentation",
            zoneID: workZone.id,
            duration: TaskDuration(minutes: 90),
            isSplittable: true
        )
        try await taskRepository.addTask(filler)
        try await taskRepository.addTask(overflow)
        try await sessionRepository.addSession(
            Session(
                id: idGenerator.makeUUID(),
                taskID: filler.id,
                zoneID: workZone.id,
                timeRange: try range(
                    on: day,
                    startHour: 9,
                    startMinute: 0,
                    minutes: 450,
                    timeZone: timeZone
                ),
                placement: .userFixed,
                status: .planned
            )
        )

        let workspace = try await workspaceProvider.load()
        let result = try engine.makePlan(
            for: SchedulingSnapshot(
                planningDay: day,
                timeZone: timeZone,
                zones: workspace.zones,
                goals: [],
                tasks: [overflow],
                sessions: workspace.sessions
            )
        )
        return ScheduleOperationResult(
            workspace: workspace,
            nudge: result.issues.first.map(ScheduleNudge.schedulingIssue)
        )
    }

    private func simulateMissedChain(
        on day: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        let workZone = try await requiredWorkZone()
        guard let startDay = date(byAddingDays: -1, to: day, in: timeZone) else {
            throw SchedulingError.invalidTimeRange
        }
        let created = try await createGoalUseCase.execute(
            CreateSevenTaskGoalRequest(
                name: "Ship portfolio",
                zoneID: workZone.id,
                taskDurationMinutes: 60,
                startDay: startDay,
                timeZone: timeZone
            )
        )
        guard let goal = created.workspace.goals.first,
              let first = created.workspace.tasks.first(
                where: { $0.goalID == goal.id && $0.dependencyIDs.isEmpty }
              ),
              let successor = created.workspace.tasks.first(
                where: { $0.dependencyIDs.contains(first.id) }
              ),
              let missedSession = created.workspace.sessions.first(
                where: { $0.taskID == first.id }
              ) else {
            throw SchedulingError.invalidScenarioState
        }
        try await sessionRepository.updateSession(
            missedSession.replacing(status: .missed)
        )
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: .missedDependencyChain(
                goalID: goal.id,
                missedTaskID: first.id,
                successorTaskID: successor.id
            )
        )
    }

    private func simulateZoneReconfiguration(
        on day: Date,
        in timeZone: TimeZone
    ) async throws -> ScheduleOperationResult {
        let previous = try await requiredWorkZone()
        let task = try demoTask(
            title: "Morning planning",
            zoneID: previous.id,
            minutes: 60
        )
        let session = Session(
            id: idGenerator.makeUUID(),
            taskID: task.id,
            zoneID: previous.id,
            timeRange: try range(
                on: day,
                startHour: 9,
                startMinute: 0,
                minutes: 60,
                timeZone: timeZone
            ),
            placement: .engineManaged,
            status: .planned
        )
        try await taskRepository.addTask(task)
        try await sessionRepository.addSession(session)
        let updated = Zone(
            id: previous.id,
            name: previous.name,
            color: previous.color,
            startTime: try LocalTime(hour: 10, minute: 0),
            endTime: try LocalTime(hour: 16, minute: 0)
        )
        try await zoneRepository.updateZone(updated)
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: .zoneReconfigured(
                zoneID: updated.id,
                previousZone: previous,
                affectedSessionIDs: [session.id]
            )
        )
    }

    private func requiredWorkZone() async throws -> Zone {
        guard let zone = try await zoneRepository.fetchZones()
            .first(where: { $0.name == "Work" }) else {
            throw SchedulingError.invalidScenarioState
        }
        return zone
    }

    private func demoTask(
        title: String,
        zoneID: UUID,
        minutes: Int
    ) throws -> AwanTask {
        try AwanTask(
            id: idGenerator.makeUUID(),
            title: title,
            zoneID: zoneID,
            duration: TaskDuration(minutes: minutes),
            isSplittable: false
        )
    }

    private func range(
        on day: Date,
        startHour: Int,
        startMinute: Int,
        minutes: Int,
        timeZone: TimeZone
    ) throws -> TimeRange {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = startHour
        components.minute = startMinute
        guard let start = calendar.date(from: components) else {
            throw SchedulingError.invalidTimeRange
        }
        return try TimeRange(
            start: start,
            end: start.addingTimeInterval(TimeInterval(minutes * 60))
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
