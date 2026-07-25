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

    public func removeOrphanedZones() throws {
        let templateIDs = Set(
            try modelContext.fetch(FetchDescriptor<TemplateModel>()).map(\.id)
        )
        let templateOverrideIDs = Set(
            try modelContext.fetch(FetchDescriptor<TemplateOverrideModel>()).map(\.id)
        )
        let zones = try modelContext.fetch(FetchDescriptor<ZoneModel>())
        var removedAny = false

        for zone in zones {
            let hasTemplate = zone.templateID.map(templateIDs.contains) ?? false
            let hasTemplateOverride = zone.templateOverrideID
                .map(templateOverrideIDs.contains) ?? false
            guard zone.hasValidOwner, hasTemplate != hasTemplateOverride else {
                modelContext.delete(zone)
                removedAny = true
                continue
            }
        }

        if removedAny {
            try modelContext.save()
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
