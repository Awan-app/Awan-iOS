import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTemplateDataSource: LocalTemplateDataSource {
    public func fetchTemplates() throws -> [TemplateData] {
        let context = ModelContext(modelContainer)
        var result: [TemplateData] = []
        for model in try context.fetch(FetchDescriptor<TemplateModel>()) {
            result.append(try makeData(model, in: context))
        }
        return result
    }

    public func fetchTemplate(forWeekDay weekDay: Int) throws -> TemplateData? {
        guard (1...7).contains(weekDay) else {
            throw SchedulingPersistenceError.invalidWeekDays([weekDay])
        }
        let context = ModelContext(modelContainer)
        let matches = try context.fetch(FetchDescriptor<TemplateModel>())
            .filter { $0.weekDaysRaw.contains(weekDay) }
        guard matches.count <= 1 else {
            throw SchedulingPersistenceError.overlappingTemplateWeekDays([weekDay])
        }
        guard let match = matches.first else { return nil }
        return try makeData(match, in: context)
    }

    public func addTemplate(_ template: TemplateData) throws {
        try validateWeekDays(template.weekDays)
        guard try find(id: template.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(template.id)
        }
        try validateNoOverlap(for: template, excluding: nil)
        try validateNewZoneIDs(template.zones)

        modelContext.insert(
            TemplateModel(
                id: template.id,
                name: template.name,
                createdAt: template.createdAt,
                weekDaysRaw: template.weekDays.sorted()
            )
        )
        for zone in template.zones {
            modelContext.insert(
                ZoneModel(domain: zone, templateID: template.id, templateOverrideID: nil)
            )
        }
        try modelContext.save()
    }

    public func updateTemplate(_ template: TemplateData) throws {
        try validateWeekDays(template.weekDays)
        guard let model = try find(id: template.id) else {
            throw SchedulingError.entityNotFound(id: template.id)
        }
        try validateNoOverlap(for: template, excluding: template.id)
        let allZones = try modelContext.fetch(FetchDescriptor<ZoneModel>())
        try validateZoneOwnership(template.zones, ownerID: template.id, in: allZones)

        model.name = template.name
        model.createdAt = template.createdAt
        model.weekDaysRaw = template.weekDays.sorted()
        try reconcileZones(template.zones, ownerID: template.id, allZones: allZones)
        try modelContext.save()
    }

    public func deleteTemplate(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        for zone in try zones(templateID: id) {
            modelContext.delete(zone)
        }
        modelContext.delete(model)
        try modelContext.save()
    }

    public func deleteAllTemplates() throws {
        for zone in try modelContext.fetch(FetchDescriptor<ZoneModel>())
        where zone.templateID != nil {
            modelContext.delete(zone)
        }
        for model in try modelContext.fetch(FetchDescriptor<TemplateModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    private func find(id: UUID) throws -> TemplateModel? {
        let targetID = id
        var descriptor = FetchDescriptor<TemplateModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func makeData(_ model: TemplateModel, in context: ModelContext) throws -> TemplateData {
        let ownedZones = try zones(templateID: model.id, in: context)
        for zone in ownedZones where !zone.hasValidOwner {
            throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
        }
        return TemplateData(
            id: model.id,
            name: model.name,
            createdAt: model.createdAt,
            weekDays: Set(model.weekDaysRaw),
            zones: try ownedZones.map { try $0.toDomain() }
                .sorted { $0.startTime < $1.startTime }
        )
    }

    private func zones(templateID: UUID) throws -> [ZoneModel] {
        try zones(templateID: templateID, in: modelContext)
    }

    private func zones(templateID: UUID, in context: ModelContext) throws -> [ZoneModel] {
        let ownerID = templateID
        return try context.fetch(
            FetchDescriptor<ZoneModel>(
                predicate: #Predicate { $0.templateID == ownerID }
            )
        )
    }

    private func validateWeekDays(_ weekDays: Set<Int>) throws {
        guard !weekDays.isEmpty, weekDays.allSatisfy({ (1...7).contains($0) }) else {
            throw SchedulingPersistenceError.invalidWeekDays(weekDays)
        }
    }

    private func validateNoOverlap(for template: TemplateData, excluding id: UUID?) throws {
        let overlap = try modelContext.fetch(FetchDescriptor<TemplateModel>())
            .filter { $0.id != id }
            .map { Set($0.weekDaysRaw).intersection(template.weekDays) }
            .reduce(into: Set<Int>()) { $0.formUnion($1) }
        guard overlap.isEmpty else {
            throw SchedulingPersistenceError.overlappingTemplateWeekDays(overlap)
        }
    }

    private func validateNewZoneIDs(_ zones: [Zone]) throws {
        guard Set(zones.map(\.id)).count == zones.count else {
            throw SchedulingPersistenceError.duplicateZoneID(
                zones.first?.id ?? UUID()
            )
        }
        let existingIDs = Set(
            try modelContext.fetch(FetchDescriptor<ZoneModel>()).map(\.id)
        )
        if let duplicate = zones.first(where: { existingIDs.contains($0.id) }) {
            throw SchedulingPersistenceError.duplicateZoneID(duplicate.id)
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
            guard model.templateID == ownerID, model.templateOverrideID == nil else {
                throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
            }
        }
    }

    private func reconcileZones(
        _ zones: [Zone],
        ownerID: UUID,
        allZones: [ZoneModel]
    ) throws {
        let desiredIDs = Set(zones.map(\.id))
        let owned = allZones.filter { $0.templateID == ownerID }
        let ownedByID = Dictionary(uniqueKeysWithValues: owned.map { ($0.id, $0) })
        for model in owned where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for zone in zones {
            if let model = ownedByID[zone.id] {
                model.update(from: zone)
            } else {
                modelContext.insert(
                    ZoneModel(domain: zone, templateID: ownerID, templateOverrideID: nil)
                )
            }
        }
    }
}
