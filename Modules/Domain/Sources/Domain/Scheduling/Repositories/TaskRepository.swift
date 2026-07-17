import Foundation

public protocol TaskRepository: Sendable {
    func fetchTasks() async throws -> [AwanTask]
    func addTask(_ task: AwanTask) async throws
    func updateTask(_ task: AwanTask) async throws
    func deleteTask(id: UUID) async throws
    func deleteAllTasks() async throws
}
