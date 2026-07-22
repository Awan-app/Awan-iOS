import Combine
import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataSessionDataSource: LocalSessionDataSource {
    private let changes = LocalDataObservationHub()

    public nonisolated func observeSessions() -> AnyPublisher<[Session], Error> {
        changes.publisher()
            .prepend(())
            .flatMap(maxPublishers: .max(1)) { [self] _ in
                AsyncValuePublisher.make { try await self.fetchSessions() }
            }
            .eraseToAnyPublisher()
    }

    public func fetchSessions() throws -> [Session] {
        try modelContext.fetch(FetchDescriptor<SessionModel>()).map { try $0.toDomain() }
    }

    public func replaceAllSessions(_ sessions: [Session]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<SessionModel>())
        try reconcile(sessions, replacing: existing)
    }

    public func replaceSessions(_ sessions: [Session], forDay dayKey: String) throws {
        let existing = try modelContext.fetch(FetchDescriptor<SessionModel>())
        let scoped = existing.filter { LocalDateKey.value(for: $0.startDate) == dayKey }
        try reconcile(sessions, replacing: scoped, existing: existing)
    }

    private func reconcile(
        _ sessions: [Session],
        replacing replacedModels: [SessionModel],
        existing: [SessionModel]? = nil
    ) throws {
        let allExisting = existing ?? replacedModels
        let desiredIDs = Set(sessions.map(\.id))
        let existingByID = Dictionary(uniqueKeysWithValues: allExisting.map { ($0.id, $0) })

        for model in replacedModels where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for session in sessions {
            if let model = existingByID[session.id] {
                model.update(from: session)
            } else {
                modelContext.insert(SessionModel(domain: session))
            }
        }
        try modelContext.save()
        changes.send()
    }

    public func addSession(_ session: Session) throws {
        guard try find(id: session.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(session.id)
        }
        modelContext.insert(SessionModel(domain: session))
        try modelContext.save()
        changes.send()
    }

    public func updateSession(_ session: Session) throws {
        guard let model = try find(id: session.id) else {
            throw SchedulingError.entityNotFound(id: session.id)
        }
        model.update(from: session)
        try modelContext.save()
        changes.send()
    }

    public func deleteSession(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
        changes.send()
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
        changes.send()
    }

    public func deleteAllSessions() throws {
        for model in try modelContext.fetch(FetchDescriptor<SessionModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
        changes.send()
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
