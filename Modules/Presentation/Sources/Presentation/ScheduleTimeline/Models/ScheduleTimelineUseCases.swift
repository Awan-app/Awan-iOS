import Domain

public struct ScheduleTaskUseCases: Sendable {
    public let create: any CreateTaskUseCase
    public let update: any UpdateTaskUseCase
    public let delete: any DeleteTaskUseCase

    public init(
        create: any CreateTaskUseCase,
        update: any UpdateTaskUseCase,
        delete: any DeleteTaskUseCase
    ) {
        self.create = create
        self.update = update
        self.delete = delete
    }
}

public struct ScheduleGoalUseCases: Sendable {
    public let createSevenTaskGoal: any CreateSevenTaskGoalUseCase

    public init(createSevenTaskGoal: any CreateSevenTaskGoalUseCase) {
        self.createSevenTaskGoal = createSevenTaskGoal
    }
}

public struct ScheduleSessionUseCases: Sendable {
    public let move: any MoveSessionUseCase

    public init(move: any MoveSessionUseCase) {
        self.move = move
    }
}

public struct ScheduleConflictUseCases: Sendable {
    public let applyCandidate: any ApplyScheduleCandidateUseCase
    public let separateOverlap: any SeparateOverlappingSessionsUseCase
    public let moveOverlap: any MoveOverlappingSessionUseCase
    public let shiftGoalChain: any ShiftGoalDependencyChainUseCase
    public let stackTasks: any StackDependentTasksUseCase
    public let makeTaskIndependent: any MakeTaskIndependentUseCase
    public let replanZoneSessions: any ReplanZoneSessionsUseCase
    public let restoreZone: any RestoreZoneUseCase
    public let keepFixedOverAllocation: any KeepFixedOverAllocationUseCase
    public let trimFixedOverAllocation: any TrimFixedOverAllocationUseCase
    public let keepFixedSessionsOutsideZone: any KeepFixedSessionsOutsideZoneUseCase
    public let moveFixedSessionsIntoZone: any MoveFixedSessionsIntoZoneUseCase
    public let restoreTaskZone: any RestoreTaskZoneUseCase

    public init(
        applyCandidate: any ApplyScheduleCandidateUseCase,
        separateOverlap: any SeparateOverlappingSessionsUseCase,
        moveOverlap: any MoveOverlappingSessionUseCase,
        shiftGoalChain: any ShiftGoalDependencyChainUseCase,
        stackTasks: any StackDependentTasksUseCase,
        makeTaskIndependent: any MakeTaskIndependentUseCase,
        replanZoneSessions: any ReplanZoneSessionsUseCase,
        restoreZone: any RestoreZoneUseCase,
        keepFixedOverAllocation: any KeepFixedOverAllocationUseCase,
        trimFixedOverAllocation: any TrimFixedOverAllocationUseCase,
        keepFixedSessionsOutsideZone: any KeepFixedSessionsOutsideZoneUseCase,
        moveFixedSessionsIntoZone: any MoveFixedSessionsIntoZoneUseCase,
        restoreTaskZone: any RestoreTaskZoneUseCase
    ) {
        self.applyCandidate = applyCandidate
        self.separateOverlap = separateOverlap
        self.moveOverlap = moveOverlap
        self.shiftGoalChain = shiftGoalChain
        self.stackTasks = stackTasks
        self.makeTaskIndependent = makeTaskIndependent
        self.replanZoneSessions = replanZoneSessions
        self.restoreZone = restoreZone
        self.keepFixedOverAllocation = keepFixedOverAllocation
        self.trimFixedOverAllocation = trimFixedOverAllocation
        self.keepFixedSessionsOutsideZone = keepFixedSessionsOutsideZone
        self.moveFixedSessionsIntoZone = moveFixedSessionsIntoZone
        self.restoreTaskZone = restoreTaskZone
    }
}

public struct ScheduleSimulationUseCases: Sendable {
    public let simulate: any SimulateScheduleScenarioUseCase
    public let reset: any ResetScheduleSimulationUseCase

    public init(
        simulate: any SimulateScheduleScenarioUseCase,
        reset: any ResetScheduleSimulationUseCase
    ) {
        self.simulate = simulate
        self.reset = reset
    }
}

public struct ScheduleTimelineUseCases: Sendable {
    public let workspace: any LoadScheduleWorkspaceUseCase
    public let tasks: ScheduleTaskUseCases
    public let goals: ScheduleGoalUseCases
    public let sessions: ScheduleSessionUseCases
    public let conflicts: ScheduleConflictUseCases
    public let simulation: ScheduleSimulationUseCases

    public init(
        workspace: any LoadScheduleWorkspaceUseCase,
        tasks: ScheduleTaskUseCases,
        goals: ScheduleGoalUseCases,
        sessions: ScheduleSessionUseCases,
        conflicts: ScheduleConflictUseCases,
        simulation: ScheduleSimulationUseCases
    ) {
        self.workspace = workspace
        self.tasks = tasks
        self.goals = goals
        self.sessions = sessions
        self.conflicts = conflicts
        self.simulation = simulation
    }
}
