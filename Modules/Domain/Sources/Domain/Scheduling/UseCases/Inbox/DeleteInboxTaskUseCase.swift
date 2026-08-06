//
//  DeleteInboxTaskUseCase.swift
//  Domain
//

import Foundation

public protocol DeleteInboxTaskUseCase: Sendable {
    func execute(taskID: UUID) async throws
}

public struct DefaultDeleteInboxTaskUseCase: DeleteInboxTaskUseCase {
    private let taskRepository: any TaskRepository

    public init(taskRepository: any TaskRepository) {
        self.taskRepository = taskRepository
    }

    public func execute(taskID: UUID) async throws {
        try await taskRepository.deleteTask(id: taskID)
    }
}
