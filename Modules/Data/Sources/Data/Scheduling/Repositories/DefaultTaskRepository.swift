import Domain
import Foundation

public struct DefaultTaskRepository: TaskRepository {
    private let localDataSource: any LocalTaskDataSource

    public init(localDataSource: any LocalTaskDataSource) {
        self.localDataSource = localDataSource
    }

    public func fetchTasks() async throws -> [AwanTask] {
        try await localDataSource.fetchTasks()
    }
    public func addTask(_ task: AwanTask) async throws {
        try await localDataSource.addTask(task)
    }
    public func updateTask(_ task: AwanTask) async throws {
        try await localDataSource.updateTask(task)
    }
    public func deleteTask(id: UUID) async throws {
        try await localDataSource.deleteTask(id: id)
    }
    public func deleteAllTasks() async throws {
        try await localDataSource.deleteAllTasks()
    }
    public func addDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await localDataSource.addDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    public func removeDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await localDataSource.removeDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    public func fetchDependencies(taskID: UUID) async throws -> [AwanTask] {
        try await localDataSource.fetchDependencies(taskID: taskID)
    }
    public func fetchDependents(taskID: UUID) async throws -> [AwanTask] {
        try await localDataSource.fetchDependents(taskID: taskID)
    }
}
