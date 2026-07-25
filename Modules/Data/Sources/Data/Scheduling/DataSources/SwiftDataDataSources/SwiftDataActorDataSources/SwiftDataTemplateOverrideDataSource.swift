import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTemplateOverrideDataSource: LocalTemplateOverrideDataSource {
    public func fetchTemplateOverrides() throws -> [TemplateOverrideData] {
        let context = ModelContext(modelContainer)
        var result: [TemplateOverrideData] = []
        for model in try context.fetch(FetchDescriptor<TemplateOverrideModel>()) {
            result.append(try makeData(model, in: context))
        }
        return result
    }

    public func fetchTemplateOverride(for date: Date) throws -> TemplateOverrideData? {
        let dateKey = LocalDateKey.value(for: date)
        return try fetchTemplateOverride(forDateKey: dateKey)
    }

    public func fetchTemplateOverride(forDateKey dateKey: String) throws -> TemplateOverrideData? {
        let context = ModelContext(modelContainer)
        let matches = try models(dateKey: dateKey, in: context)
        guard matches.count <= 1 else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        guard let match = matches.first else { return nil }
        return try makeData(match, in: context)
    }

    public func addTemplateOverride(_ templateOverride: TemplateOverrideData) throws {
        let dateKey = templateOverride.dateKey
        guard try find(id: templateOverride.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(templateOverride.id)
        }
        guard try models(dateKey: dateKey).isEmpty else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        try validateNewZoneIDs(templateOverride.zones)

        modelContext.insert(
            TemplateOverrideModel(
                id: templateOverride.id,
                dateKey: dateKey,
                name: templateOverride.name,
                createdAt: templateOverride.createdAt,
                dateOfDay: LocalDateKey.startOfDay(for: templateOverride.dateOfDay)
            )
        )
        for zone in templateOverride.zones {
            modelContext.insert(
                ZoneModel(
                    domain: zone,
                    templateID: nil,
                    templateOverrideID: templateOverride.id
                )
            )
        }
        try modelContext.save()
    }

    public func replaceTemplateOverrides(
        _ templateOverrides: [TemplateOverrideData]
    ) throws {
        try validateReplacement(templateOverrides)

        let existingOverrides = try modelContext.fetch(
            FetchDescriptor<TemplateOverrideModel>()
        )
        let existingZones = try modelContext.fetch(FetchDescriptor<ZoneModel>())
        let desiredOverrideIDs = Set(templateOverrides.map(\.id))
        let desiredZoneIDs = Set(templateOverrides.flatMap(\.zones).map(\.id))
        let overridesByID = Dictionary(
            uniqueKeysWithValues: existingOverrides.map { ($0.id, $0) }
        )
        let zonesByID = Dictionary(uniqueKeysWithValues: existingZones.map { ($0.id, $0) })

        for model in existingOverrides where !desiredOverrideIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for model in existingZones
        where model.templateOverrideID != nil && !desiredZoneIDs.contains(model.id) {
            modelContext.delete(model)
        }

        for templateOverride in templateOverrides {
            if let model = overridesByID[templateOverride.id] {
                model.dateKey = templateOverride.dateKey
                model.name = templateOverride.name
                model.dateOfDay = templateOverride.dateOfDay
            } else {
                modelContext.insert(
                    TemplateOverrideModel(
                        id: templateOverride.id,
                        dateKey: templateOverride.dateKey,
                        name: templateOverride.name,
                        createdAt: templateOverride.createdAt,
                        dateOfDay: templateOverride.dateOfDay
                    )
                )
            }

            for zone in templateOverride.zones {
                if let model = zonesByID[zone.id] {
                    model.update(from: zone)
                    model.templateID = nil
                    model.templateOverrideID = templateOverride.id
                } else {
                    modelContext.insert(
                        ZoneModel(
                            domain: zone,
                            templateID: nil,
                            templateOverrideID: templateOverride.id
                        )
                    )
                }
            }
        }
        try modelContext.save()
    }

    public func updateTemplateOverride(_ templateOverride: TemplateOverrideData) throws {
        let dateKey = templateOverride.dateKey
        guard let model = try find(id: templateOverride.id) else {
            throw SchedulingError.entityNotFound(id: templateOverride.id)
        }
        let conflicting = try models(dateKey: dateKey).filter { $0.id != templateOverride.id }
        guard conflicting.isEmpty else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        let allZones = try modelContext.fetch(FetchDescriptor<ZoneModel>())
        try validateZoneOwnership(
            templateOverride.zones,
            ownerID: templateOverride.id,
            in: allZones
        )

        model.dateKey = dateKey
        model.name = templateOverride.name
        model.createdAt = templateOverride.createdAt
        model.dateOfDay = LocalDateKey.startOfDay(for: templateOverride.dateOfDay)
        reconcileZones(templateOverride.zones, ownerID: templateOverride.id, allZones: allZones)
        try modelContext.save()
    }

    public func deleteTemplateOverride(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        for zone in try zones(templateOverrideID: id) {
            modelContext.delete(zone)
        }
        modelContext.delete(model)
        try modelContext.save()
    }

    public func deleteAllTemplateOverrides() throws {
        for zone in try modelContext.fetch(FetchDescriptor<ZoneModel>())
        where zone.templateOverrideID != nil {
            modelContext.delete(zone)
        }
        for model in try modelContext.fetch(FetchDescriptor<TemplateOverrideModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    private func find(id: UUID) throws -> TemplateOverrideModel? {
        let targetID = id
        var descriptor = FetchDescriptor<TemplateOverrideModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func models(dateKey: String) throws -> [TemplateOverrideModel] {
        try models(dateKey: dateKey, in: modelContext)
    }

    private func models(
        dateKey: String,
        in context: ModelContext
    ) throws -> [TemplateOverrideModel] {
        let targetDateKey = dateKey
        return try context.fetch(
            FetchDescriptor<TemplateOverrideModel>(
                predicate: #Predicate { $0.dateKey == targetDateKey }
            )
        )
    }

    private func makeData(
        _ model: TemplateOverrideModel,
        in context: ModelContext
    ) throws -> TemplateOverrideData {
        let ownedZones = try zones(templateOverrideID: model.id, in: context)
        for zone in ownedZones where !zone.hasValidOwner {
            throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
        }
        return TemplateOverrideData(
            id: model.id,
            name: model.name,
            createdAt: model.createdAt,
            dateKey: model.dateKey,
            dateOfDay: model.dateOfDay,
            zones: try ownedZones.map { try $0.toDomain() }
                .sorted { $0.startTime < $1.startTime }
        )
    }

    private func zones(templateOverrideID: UUID) throws -> [ZoneModel] {
        try zones(templateOverrideID: templateOverrideID, in: modelContext)
    }

    private func zones(
        templateOverrideID: UUID,
        in context: ModelContext
    ) throws -> [ZoneModel] {
        let ownerID = templateOverrideID
        return try context.fetch(
            FetchDescriptor<ZoneModel>(
                predicate: #Predicate { $0.templateOverrideID == ownerID }
            )
        )
    }

    private func validateNewZoneIDs(_ zones: [Zone]) throws {
        guard Set(zones.map(\.id)).count == zones.count else {
            throw SchedulingPersistenceError.duplicateZoneID(zones.first?.id ?? UUID())
        }
        let existingIDs = Set(
            try modelContext.fetch(FetchDescriptor<ZoneModel>()).map(\.id)
        )
        if let duplicate = zones.first(where: { existingIDs.contains($0.id) }) {
            throw SchedulingPersistenceError.duplicateZoneID(duplicate.id)
        }
    }

    private func validateReplacement(
        _ templateOverrides: [TemplateOverrideData]
    ) throws {
        let overrideIDs = templateOverrides.map(\.id)
        guard Set(overrideIDs).count == overrideIDs.count else {
            throw SchedulingPersistenceError.duplicateID(
                overrideIDs.first ?? UUID()
            )
        }

        var claimedDateKeys = Set<String>()
        var claimedZoneIDs = Set<UUID>()
        for templateOverride in templateOverrides {
            guard claimedDateKeys.insert(templateOverride.dateKey).inserted else {
                throw SchedulingPersistenceError.duplicateOverrideDate(
                    templateOverride.dateKey
                )
            }
            for zone in templateOverride.zones {
                guard claimedZoneIDs.insert(zone.id).inserted else {
                    throw SchedulingPersistenceError.duplicateZoneID(zone.id)
                }
            }
        }

        let templateZoneIDs = Set(
            try modelContext.fetch(FetchDescriptor<ZoneModel>())
                .filter {
                    $0.templateID != nil && $0.templateOverrideID == nil
                }
                .map(\.id)
        )
        if let conflict = claimedZoneIDs.first(where: templateZoneIDs.contains) {
            throw SchedulingPersistenceError.invalidZoneOwnership(conflict)
        }
    }

    private func validateZoneOwnership(
        _ zones: [Zone],
        ownerID: UUID,
        in existing: [ZoneModel]
    ) throws {
        guard Set(zones.map(\.id)).count == zones.count else {
            throw SchedulingPersistenceError.duplicateZoneID(zones.first?.id ?? UUID())
        }
        let modelsByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        for zone in zones {
            guard let model = modelsByID[zone.id] else { continue }
            guard model.templateOverrideID == ownerID, model.templateID == nil else {
                throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
            }
        }
    }

    private func reconcileZones(
        _ zones: [Zone],
        ownerID: UUID,
        allZones: [ZoneModel]
    ) {
        let desiredIDs = Set(zones.map(\.id))
        let owned = allZones.filter { $0.templateOverrideID == ownerID }
        let ownedByID = Dictionary(uniqueKeysWithValues: owned.map { ($0.id, $0) })
        for model in owned where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for zone in zones {
            if let model = ownedByID[zone.id] {
                model.update(from: zone)
            } else {
                modelContext.insert(
                    ZoneModel(domain: zone, templateID: nil, templateOverrideID: ownerID)
                )
            }
        }
    }
}
