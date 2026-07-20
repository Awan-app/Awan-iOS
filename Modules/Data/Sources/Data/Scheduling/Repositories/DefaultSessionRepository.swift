import Domain
import Foundation

public struct DefaultSessionRepository: SessionRepository {
    private let localDataSource: any LocalSessionDataSource

    public init(localDataSource: any LocalSessionDataSource) {
        self.localDataSource = localDataSource
    }

    public func fetchSessions() async throws -> [Session] {
        try await localDataSource.fetchSessions()
    }
    public func addSession(_ session: Session) async throws {
        try await localDataSource.addSession(session)
    }
    public func updateSession(_ session: Session) async throws {
        try await localDataSource.updateSession(session)
    }
    public func deleteSession(id: UUID) async throws {
        try await localDataSource.deleteSession(id: id)
    }
    public func deleteSessions(taskID: UUID) async throws {
        try await localDataSource.deleteSessions(taskID: taskID)
    }
    public func deleteAllSessions() async throws {
        try await localDataSource.deleteAllSessions()
    }
}
