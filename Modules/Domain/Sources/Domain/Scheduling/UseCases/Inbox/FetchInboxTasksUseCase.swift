//
//  FetchInboxTasksUseCase.swift
//  Domain
//

import Combine
import Foundation

public protocol FetchInboxTasksUseCase: Sendable {
    func execute() async throws -> [InboxTask]
    func observe() -> AnyPublisher<[InboxTask], Error>
}

public extension FetchInboxTasksUseCase {
    func observe() -> AnyPublisher<[InboxTask], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchInboxTasksUseCase: FetchInboxTasksUseCase {
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let deriveStatus: DeriveInboxTaskStatusService

    public init(
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        deriveStatus: DeriveInboxTaskStatusService = DeriveInboxTaskStatusService()
    ) {
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.deriveStatus = deriveStatus
    }

    public func execute() async throws -> [InboxTask] {
        async let tasksResult = taskRepository.fetchInboxTasks()
        async let sessionsResult = sessionRepository.fetchSessions()

        let (inboxTasks, allSessions) = try await (tasksResult, sessionsResult)
        let sessionsByTaskID = Dictionary(grouping: allSessions, by: \.taskID)

        return inboxTasks.map { task in
            let taskSessions = sessionsByTaskID[task.id] ?? []
            let status = deriveStatus.derive(from: taskSessions, taskStatus: task.status)
            return InboxTask(task: task, sessions: taskSessions, derivedStatus: status)
        }
    }

    public func observe() -> AnyPublisher<[InboxTask], Error> {
        Publishers.CombineLatest(
            taskRepository.observeInboxTasks(),
            sessionRepository.observeSessions()
        )
        .map { [deriveStatus] inboxTasks, allSessions in
            let sessionsByTaskID = Dictionary(grouping: allSessions, by: \.taskID)
            return inboxTasks.map { task in
                let taskSessions = sessionsByTaskID[task.id] ?? []
                let status = deriveStatus.derive(from: taskSessions, taskStatus: task.status)
                return InboxTask(task: task, sessions: taskSessions, derivedStatus: status)
            }
        }
        .eraseToAnyPublisher()
    }
}
