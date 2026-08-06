//
//  FetchGoalsWithTasksUseCase.swift
//  Domain
//

import Combine
import Foundation

public protocol FetchGoalsWithTasksUseCase: Sendable {
    func execute() async throws -> [GoalWithTasks]
    func observe() -> AnyPublisher<[GoalWithTasks], Error>
}

public extension FetchGoalsWithTasksUseCase {
    func observe() -> AnyPublisher<[GoalWithTasks], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchGoalsWithTasksUseCase: FetchGoalsWithTasksUseCase {
    private let goalRepository: any GoalRepository
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let deriveStatus: DeriveInboxTaskStatusService

    public init(
        goalRepository: any GoalRepository,
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        deriveStatus: DeriveInboxTaskStatusService = DeriveInboxTaskStatusService()
    ) {
        self.goalRepository = goalRepository
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.deriveStatus = deriveStatus
    }

    public func execute() async throws -> [GoalWithTasks] {
        async let goalsResult = goalRepository.fetchGoals()
        async let tasksResult = taskRepository.fetchTasks()
        async let sessionsResult = sessionRepository.fetchSessions()

        let (goals, allTasks, allSessions) = try await (goalsResult, tasksResult, sessionsResult)
        return build(goals: goals, allTasks: allTasks, allSessions: allSessions)
    }

    public func observe() -> AnyPublisher<[GoalWithTasks], Error> {
        Publishers.CombineLatest3(
            goalRepository.observeGoals(),
            taskRepository.observeTasks(),
            sessionRepository.observeSessions()
        )
        .map { [deriveStatus] goals, allTasks, allSessions in
            DefaultFetchGoalsWithTasksUseCase.build(goals: goals, allTasks: allTasks, allSessions: allSessions, deriveStatus: deriveStatus)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func build(
        goals: [Goal],
        allTasks: [AwanTask],
        allSessions: [Session]
    ) -> [GoalWithTasks] {
        Self.build(goals: goals, allTasks: allTasks, allSessions: allSessions, deriveStatus: deriveStatus)
    }

    private static func build(
        goals: [Goal],
        allTasks: [AwanTask],
        allSessions: [Session],
        deriveStatus: DeriveInboxTaskStatusService
    ) -> [GoalWithTasks] {
        let tasksByGoalID = Dictionary(grouping: allTasks.filter { $0.goalID != nil }, by: { $0.goalID! })
        let sessionsByTaskID = Dictionary(grouping: allSessions, by: \.taskID)

        return goals.map { goal in
            let goalTasks = tasksByGoalID[goal.id] ?? []
            let inboxTasks = goalTasks.map { task -> InboxTask in
                let sessions = sessionsByTaskID[task.id] ?? []
                let status = deriveStatus.derive(from: sessions, taskStatus: task.status)
                return InboxTask(task: task, sessions: sessions, derivedStatus: status)
            }
            return GoalWithTasks(goal: goal, tasks: inboxTasks)
        }
    }
}
