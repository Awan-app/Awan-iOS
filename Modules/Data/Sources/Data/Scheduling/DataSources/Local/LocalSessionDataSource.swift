import Domain
import Foundation

public protocol LocalSessionDataSource: Sendable {
    func fetchSessions() async throws -> [Session]
    func replaceSessions(_ sessions: [Session]) async throws
    func addSession(_ session: Session) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
}

public extension LocalSessionDataSource {
    func replaceSessions(_ sessions: [Session]) async throws {
        let existing = try await fetchSessions()
        let existingIDs = Set(existing.map(\.id))
        let desiredIDs = Set(sessions.map(\.id))
        for session in existing where !desiredIDs.contains(session.id) {
            try await deleteSession(id: session.id)
        }
        for session in sessions {
            if existingIDs.contains(session.id) {
                try await updateSession(session)
            } else {
                try await addSession(session)
            }
        }
    }
}
