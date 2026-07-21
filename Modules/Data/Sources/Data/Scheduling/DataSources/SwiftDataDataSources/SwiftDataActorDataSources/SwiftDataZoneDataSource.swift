import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataZoneDataSource: LocalZoneDataSource {
    public func validateOwnership() throws {
        let context = ModelContext(modelContainer)
        if let invalid = try context.fetch(FetchDescriptor<ZoneModel>())
            .first(where: { !$0.hasValidOwner }) {
            throw SchedulingPersistenceError.invalidZoneOwnership(invalid.id)
        }
    }

    public func updateZone(_ zone: Zone) throws {
        guard let model = try find(id: zone.id) else {
            throw SchedulingError.entityNotFound(id: zone.id)
        }
        guard model.hasValidOwner else {
            throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
        }
        model.update(from: zone)
        try modelContext.save()
    }

    private func find(id: UUID) throws -> ZoneModel? {
        let targetID = id
        var descriptor = FetchDescriptor<ZoneModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
