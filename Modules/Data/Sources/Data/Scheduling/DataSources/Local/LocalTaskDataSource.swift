import Domain
import Foundation

public protocol LocalTaskDataSource: Sendable {
    func fetchTasks() async throws -> [AwanTask]
    func fetchTask(id: UUID) async throws -> AwanTask?
    func addTask(_ task: AwanTask) async throws
    func updateTask(_ task: AwanTask) async throws
    func deleteTask(id: UUID) async throws
    func deleteAllTasks() async throws
    func addDependency(taskID: UUID, dependsOnID: UUID) async throws
    func removeDependency(taskID: UUID, dependsOnID: UUID) async throws
    func fetchDependencies(taskID: UUID) async throws -> [AwanTask]
    func fetchDependents(taskID: UUID) async throws -> [AwanTask]
}
