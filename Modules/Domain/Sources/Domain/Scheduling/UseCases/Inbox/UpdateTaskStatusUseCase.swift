//
//  UpdateTaskStatusUseCase.swift
//  Domain
//

import Foundation

public protocol UpdateTaskStatusUseCase: Sendable {
    func execute(taskID: UUID, status: TaskStatus) async throws
}

public struct DefaultUpdateTaskStatusUseCase: UpdateTaskStatusUseCase {
    private let taskRepository: any TaskRepository

    public init(taskRepository: any TaskRepository) {
        self.taskRepository = taskRepository
    }

    public func execute(taskID: UUID, status: TaskStatus) async throws {
        let tasks = try await taskRepository.fetchTasks()
        guard let task = tasks.first(where: { $0.id == taskID }) else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        let updatedTask = AwanTask(
            id: task.id,
            title: task.title,
            description: task.description,
            status: status,
            goalID: task.goalID,
            duration: task.duration,
            isSplittable: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: task.dependencyIDs,
            category: task.category
        )
        try await taskRepository.updateTask(updatedTask)
    }
}
