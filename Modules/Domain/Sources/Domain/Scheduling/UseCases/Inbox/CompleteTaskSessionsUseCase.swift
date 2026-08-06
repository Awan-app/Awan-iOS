//
//  CompleteTaskSessionsUseCase.swift
//  Domain
//

import Foundation

public protocol CompleteTaskSessionsUseCase: Sendable {
    func execute(taskID: UUID, isCompleted: Bool) async throws
}

public extension CompleteTaskSessionsUseCase {
    func execute(taskID: UUID) async throws {
        try await execute(taskID: taskID, isCompleted: true)
    }
}

public struct DefaultCompleteTaskSessionsUseCase: CompleteTaskSessionsUseCase {
    private let sessionRepository: any SessionRepository
    private let taskRepository: any TaskRepository

    public init(
        sessionRepository: any SessionRepository,
        taskRepository: any TaskRepository
    ) {
        self.sessionRepository = sessionRepository
        self.taskRepository = taskRepository
    }

    public func execute(taskID: UUID, isCompleted: Bool) async throws {
        let targetTaskStatus: TaskStatus = isCompleted ? .completed : .pending
        let targetSessionStatus: Session.Status = isCompleted ? .completed : .planned

        let allSessions = try await sessionRepository.fetchSessions()
        let taskSessions = allSessions.filter { $0.taskID == taskID }

        for session in taskSessions {
            if isCompleted && session.status != .completed {
                let updatedSession = session.replacing(status: targetSessionStatus)
                try await sessionRepository.updateSession(updatedSession)
            } else if !isCompleted && session.status == .completed {
                let updatedSession = session.replacing(status: targetSessionStatus)
                try await sessionRepository.updateSession(updatedSession)
            }
        }

        let tasks = try await taskRepository.fetchTasks()
        if let task = tasks.first(where: { $0.id == taskID }) {
            let updatedTask = task.updatingStatus(targetTaskStatus)
            try await taskRepository.updateTask(updatedTask)
        }
    }
}
