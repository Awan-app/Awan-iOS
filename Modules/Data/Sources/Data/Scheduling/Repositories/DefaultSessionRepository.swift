import Domain
import Foundation

public struct DefaultSessionRepository: SessionRepository {
    private let store: InMemoryScheduleDataSource

    public init(store: InMemoryScheduleDataSource) { self.store = store }

    public func fetchSessions() async throws -> [Session] { await store.fetchSessions() }
    public func addSession(_ session: Session) async throws { await store.addSession(session) }
    public func updateSession(_ session: Session) async throws { await store.updateSession(session) }
    public func deleteSession(id: UUID) async throws { await store.deleteSession(id: id) }
    public func deleteSessions(taskID: UUID) async throws { await store.deleteSessions(taskID: taskID) }
    public func deleteAllSessions() async throws { await store.deleteAllSessions() }
}
