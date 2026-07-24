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

    public func upsertZone(_ zone: Zone, templateID: UUID?, templateOverrideID: UUID?) throws {
        if let model = try find(id: zone.id) {
            model.update(from: zone)
            if let templateID { model.templateID = templateID }
            if let templateOverrideID { model.templateOverrideID = templateOverrideID }
            guard model.hasValidOwner else {
                throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
            }
        } else {
            let newModel = ZoneModel(
                domain: zone,
                templateID: templateID,
                templateOverrideID: templateOverrideID
            )
            guard newModel.hasValidOwner else {
                throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
            }
            modelContext.insert(newModel)
        }
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
