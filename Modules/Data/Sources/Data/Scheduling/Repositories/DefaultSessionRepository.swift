import Domain
import Foundation

public struct DefaultSessionRepository: SessionRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchSessions() async throws -> [Session] {
        try await store.fetchSessions().map { try $0.toDomain() }
    }
    public func addSession(_ session: Session) async throws {
        try await store.addSession(SessionRecord(domain: session))
    }
    public func updateSession(_ session: Session) async throws {
        try await store.updateSession(SessionRecord(domain: session))
    }
    public func deleteSession(id: UUID) async throws {
        try await store.deleteSession(id: id)
    }
    public func deleteSessions(taskID: UUID) async throws {
        try await store.deleteSessions(taskID: taskID)
    }
    public func deleteAllSessions() async throws {
        try await store.deleteAllSessions()
    }
}
