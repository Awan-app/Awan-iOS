import Combine
import Domain
import Foundation

public protocol LocalTaskDataSource: Sendable {
    func fetchTasks() async throws -> [AwanTask]
    func observeTasks() -> AnyPublisher<[AwanTask], Error>
    func fetchTask(id: UUID) async throws -> AwanTask?
    func replaceTasks(_ tasks: [AwanTask]) async throws
    func addTask(_ task: AwanTask) async throws
    func updateTask(_ task: AwanTask) async throws
    func deleteTask(id: UUID) async throws
    func deleteAllTasks() async throws
    func addDependency(taskID: UUID, dependsOnID: UUID) async throws
    func removeDependency(taskID: UUID, dependsOnID: UUID) async throws
    func fetchDependencies(taskID: UUID) async throws -> [AwanTask]
    func fetchDependents(taskID: UUID) async throws -> [AwanTask]
}

public extension LocalTaskDataSource {
    func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { try await fetchTasks() }
    }

    func replaceTasks(_ tasks: [AwanTask]) async throws {
        let existing = try await fetchTasks()
        let existingIDs = Set(existing.map(\.id))
        let desiredIDs = Set(tasks.map(\.id))
        for task in existing where !desiredIDs.contains(task.id) {
            try await deleteTask(id: task.id)
        }
        for task in tasks {
            if existingIDs.contains(task.id) {
                try await updateTask(task)
            } else {
                try await addTask(task)
            }
        }
    }
}
