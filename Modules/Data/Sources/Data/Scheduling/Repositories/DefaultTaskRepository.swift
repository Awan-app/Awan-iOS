import Domain
import Foundation

public struct DefaultTaskRepository: TaskRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchTasks() async throws -> [AwanTask] {
        try await store.fetchTasks().map { try $0.toDomain() }
    }
    public func addTask(_ task: AwanTask) async throws {
        try await store.addTask(TaskRecord(domain: task))
    }
    public func updateTask(_ task: AwanTask) async throws {
        try await store.updateTask(TaskRecord(domain: task))
    }
    public func deleteTask(id: UUID) async throws {
        try await store.deleteTask(id: id)
    }
    public func deleteAllTasks() async throws {
        try await store.deleteAllTasks()
    }
}
