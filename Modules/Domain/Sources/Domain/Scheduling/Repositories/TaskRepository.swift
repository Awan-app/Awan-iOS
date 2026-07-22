import Combine
import Foundation

public protocol TaskRepository: Sendable {
    func fetchTasks() async throws -> [AwanTask]
    func observeTasks() -> AnyPublisher<[AwanTask], Error>
    func addTask(_ task: AwanTask) async throws
    func updateTask(_ task: AwanTask) async throws
    func deleteTask(id: UUID) async throws
    func deleteAllTasks() async throws
    func addDependency(taskID: UUID, dependsOnID: UUID) async throws
    func removeDependency(taskID: UUID, dependsOnID: UUID) async throws
    func fetchDependencies(taskID: UUID) async throws -> [AwanTask]
    func fetchDependents(taskID: UUID) async throws -> [AwanTask]
}

public extension TaskRepository {
    func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { try await fetchTasks() }
    }
}
