import Combine
import Domain
import Foundation
@testable import Data

struct LocalTaskRepositoryStub: TaskRepository {
    let dataSource: any LocalTaskDataSource
    let sessionDataSource: any LocalSessionDataSource

    func fetchTasks() async throws -> [AwanTask] { try await dataSource.fetchTasks() }
    func observeTasks() -> AnyPublisher<[AwanTask], Error> { dataSource.observeTasks() }
    func addTask(
        _ task: AwanTask,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) async throws -> (task: AwanTask, sessions: [Session]) {
        try await dataSource.addTask(task)
        return (task, [])
    }
    func updateTask(_ task: AwanTask) async throws { try await dataSource.updateTask(task) }
    func deleteTask(id: UUID) async throws {
        try await sessionDataSource.deleteSessions(taskID: id)
        try await dataSource.deleteTask(id: id)
    }
    func deleteAllTasks() async throws { try await dataSource.deleteAllTasks() }
    func addDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await dataSource.addDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    func removeDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await dataSource.removeDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    func fetchDependencies(taskID: UUID) async throws -> [AwanTask] {
        try await dataSource.fetchDependencies(taskID: taskID)
    }
    func fetchDependents(taskID: UUID) async throws -> [AwanTask] {
        try await dataSource.fetchDependents(taskID: taskID)
    }
}

struct LocalSessionRepositoryStub: SessionRepository {
    let dataSource: any LocalSessionDataSource

    func fetchSessions() async throws -> [Session] { try await dataSource.fetchSessions() }
    func observeSessions(taskIDs: [UUID]) -> AnyPublisher<[Session], Error> {
        dataSource.observeSessions()
            .map { sessions in sessions.filter { taskIDs.contains($0.taskID) } }
            .eraseToAnyPublisher()
    }
    func addSession(_ session: Session) async throws { try await dataSource.addSession(session) }
    func updateSession(_ session: Session) async throws {
        try await dataSource.updateSession(session)
    }
    func deleteSession(id: UUID) async throws { try await dataSource.deleteSession(id: id) }
    func deleteSessions(taskID: UUID) async throws {
        try await dataSource.deleteSessions(taskID: taskID)
    }
    func deleteAllSessions() async throws { try await dataSource.deleteAllSessions() }
}
