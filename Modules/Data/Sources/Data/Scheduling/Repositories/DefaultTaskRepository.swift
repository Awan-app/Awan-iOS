import Domain
import Foundation

public struct DefaultTaskRepository: TaskRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchTasks() async throws -> [AwanTask] { await store.fetchTasks() }
    public func addTask(_ task: AwanTask) async throws { await store.addTask(task) }
    public func updateTask(_ task: AwanTask) async throws { await store.updateTask(task) }
    public func deleteTask(id: UUID) async throws { await store.deleteTask(id: id) }
    public func deleteAllTasks() async throws { await store.deleteAllTasks() }
}
