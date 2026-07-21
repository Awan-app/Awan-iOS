import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataSessionDataSource: LocalSessionDataSource {
    public func fetchSessions() throws -> [Session] {
        try modelContext.fetch(FetchDescriptor<SessionModel>()).map { try $0.toDomain() }
    }

    public func addSession(_ session: Session) throws {
        guard try find(id: session.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(session.id)
        }
        modelContext.insert(SessionModel(domain: session))
        try modelContext.save()
    }

    public func updateSession(_ session: Session) throws {
        guard let model = try find(id: session.id) else {
            throw SchedulingError.entityNotFound(id: session.id)
        }
        model.update(from: session)
        try modelContext.save()
    }

    public func deleteSession(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
    }

    public func deleteSessions(taskID: UUID) throws {
        let targetTaskID = taskID
        let descriptor = FetchDescriptor<SessionModel>(
            predicate: #Predicate { $0.taskID == targetTaskID }
        )
        for model in try modelContext.fetch(descriptor) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    public func deleteAllSessions() throws {
        for model in try modelContext.fetch(FetchDescriptor<SessionModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    private func find(id: UUID) throws -> SessionModel? {
        let targetID = id
        var descriptor = FetchDescriptor<SessionModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
