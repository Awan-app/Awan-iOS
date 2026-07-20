import Domain
import Foundation

public actor InMemorySessionDataSource: LocalSessionDataSource {
    private var sessionsByID: [UUID: Session]

    public init(sessions: [Session] = []) {
        sessionsByID = sessions.reduce(into: [:]) { $0[$1.id] = $1 }
    }

    public func fetchSessions() -> [Session] {
        Array(sessionsByID.values)
    }

    public func addSession(_ session: Session) throws {
        guard sessionsByID[session.id] == nil else {
            throw SchedulingPersistenceError.duplicateID(session.id)
        }
        sessionsByID[session.id] = session
    }

    public func updateSession(_ session: Session) throws {
        guard sessionsByID[session.id] != nil else {
            throw SchedulingError.entityNotFound(id: session.id)
        }
        sessionsByID[session.id] = session
    }

    public func deleteSession(id: UUID) {
        sessionsByID[id] = nil
    }

    public func deleteSessions(taskID: UUID) {
        sessionsByID = sessionsByID.filter { $0.value.taskID != taskID }
    }

    public func deleteAllSessions() {
        sessionsByID.removeAll()
    }
}
