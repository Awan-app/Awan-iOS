import Domain
import Foundation

public actor InMemoryZoneStorage {
    private var templatesByID: [UUID: TemplateData]
    private var overridesByID: [UUID: TemplateOverrideData]

    public init(
        templates: [TemplateData] = [],
        templateOverrides: [TemplateOverrideData] = []
    ) {
        templatesByID = templates.reduce(into: [:]) { $0[$1.id] = $1 }
        overridesByID = templateOverrides.reduce(into: [:]) { $0[$1.id] = $1 }
    }

    func validateOwnership() throws {
        var ownerCountByZoneID: [UUID: Int] = [:]
        for zone in allZones {
            ownerCountByZoneID[zone.id, default: 0] += 1
        }
        if let invalidID = ownerCountByZoneID.first(where: { $0.value != 1 })?.key {
            throw SchedulingPersistenceError.invalidZoneOwnership(invalidID)
        }
    }

    func updateZone(_ zone: Zone) throws {
        let templateOwnerIDs = templatesByID.values
            .filter { $0.zones.contains(where: { $0.id == zone.id }) }
            .map(\.id)
        let overrideOwnerIDs = overridesByID.values
            .filter { $0.zones.contains(where: { $0.id == zone.id }) }
            .map(\.id)
        guard templateOwnerIDs.count + overrideOwnerIDs.count == 1 else {
            if templateOwnerIDs.isEmpty, overrideOwnerIDs.isEmpty {
                throw SchedulingError.entityNotFound(id: zone.id)
            }
            throw SchedulingPersistenceError.invalidZoneOwnership(zone.id)
        }

        if let ownerID = templateOwnerIDs.first, let owner = templatesByID[ownerID] {
            templatesByID[ownerID] = TemplateData(
                id: owner.id,
                name: owner.name,
                createdAt: owner.createdAt,
                weekDays: owner.weekDays,
                zones: replacing(zone, in: owner.zones)
            )
        } else if let ownerID = overrideOwnerIDs.first, let owner = overridesByID[ownerID] {
            overridesByID[ownerID] = TemplateOverrideData(
                id: owner.id,
                name: owner.name,
                createdAt: owner.createdAt,
                dateOfDay: owner.dateOfDay,
                zones: replacing(zone, in: owner.zones)
            )
        }
    }

    func fetchTemplates() -> [TemplateData] {
        Array(templatesByID.values)
    }

    func fetchTemplate(forWeekDay weekDay: Int) throws -> TemplateData? {
        guard (1...7).contains(weekDay) else {
            throw SchedulingPersistenceError.invalidWeekDays([weekDay])
        }
        let matches = templatesByID.values.filter { $0.weekDays.contains(weekDay) }
        guard matches.count <= 1 else {
            throw SchedulingPersistenceError.overlappingTemplateWeekDays([weekDay])
        }
        return matches.first
    }

    func addTemplate(_ template: TemplateData) throws {
        try validateWeekDays(template.weekDays)
        guard templatesByID[template.id] == nil else {
            throw SchedulingPersistenceError.duplicateID(template.id)
        }
        try validateNoOverlap(template.weekDays, excluding: nil)
        try validateNewZones(
            template.zones,
            excludingTemplateID: nil,
            excludingOverrideID: nil,
            existingZoneError: { SchedulingPersistenceError.duplicateZoneID($0) }
        )
        templatesByID[template.id] = template
    }

    func updateTemplate(_ template: TemplateData) throws {
        try validateWeekDays(template.weekDays)
        guard templatesByID[template.id] != nil else {
            throw SchedulingError.entityNotFound(id: template.id)
        }
        try validateNoOverlap(template.weekDays, excluding: template.id)
        try validateNewZones(
            template.zones,
            excludingTemplateID: template.id,
            excludingOverrideID: nil,
            existingZoneError: { SchedulingPersistenceError.invalidZoneOwnership($0) }
        )
        templatesByID[template.id] = template
    }

    func deleteTemplate(id: UUID) {
        templatesByID[id] = nil
    }

    func deleteAllTemplates() {
        templatesByID.removeAll()
    }

    func fetchTemplateOverrides() -> [TemplateOverrideData] {
        Array(overridesByID.values)
    }

    func fetchTemplateOverride(for date: Date) throws -> TemplateOverrideData? {
        let dateKey = LocalDateKey.value(for: date)
        let matches = overridesByID.values.filter {
            LocalDateKey.value(for: $0.dateOfDay) == dateKey
        }
        guard matches.count <= 1 else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        return matches.first
    }

    func addTemplateOverride(_ templateOverride: TemplateOverrideData) throws {
        let dateKey = LocalDateKey.value(for: templateOverride.dateOfDay)
        guard overridesByID[templateOverride.id] == nil else {
            throw SchedulingPersistenceError.duplicateID(templateOverride.id)
        }
        guard !overridesByID.values.contains(where: {
            LocalDateKey.value(for: $0.dateOfDay) == dateKey
        }) else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        try validateNewZones(
            templateOverride.zones,
            excludingTemplateID: nil,
            excludingOverrideID: nil,
            existingZoneError: { SchedulingPersistenceError.duplicateZoneID($0) }
        )
        overridesByID[templateOverride.id] = normalized(templateOverride)
    }

    func updateTemplateOverride(_ templateOverride: TemplateOverrideData) throws {
        let dateKey = LocalDateKey.value(for: templateOverride.dateOfDay)
        guard overridesByID[templateOverride.id] != nil else {
            throw SchedulingError.entityNotFound(id: templateOverride.id)
        }
        guard !overridesByID.values.contains(where: {
            $0.id != templateOverride.id && LocalDateKey.value(for: $0.dateOfDay) == dateKey
        }) else {
            throw SchedulingPersistenceError.duplicateOverrideDate(dateKey)
        }
        try validateNewZones(
            templateOverride.zones,
            excludingTemplateID: nil,
            excludingOverrideID: templateOverride.id,
            existingZoneError: { SchedulingPersistenceError.invalidZoneOwnership($0) }
        )
        overridesByID[templateOverride.id] = normalized(templateOverride)
    }

    func deleteTemplateOverride(id: UUID) {
        overridesByID[id] = nil
    }

    func deleteAllTemplateOverrides() {
        overridesByID.removeAll()
    }

    private var allZones: [Zone] {
        templatesByID.values.flatMap(\.zones) + overridesByID.values.flatMap(\.zones)
    }

    private func replacing(_ zone: Zone, in zones: [Zone]) -> [Zone] {
        zones.map { $0.id == zone.id ? zone : $0 }
    }

    private func validateWeekDays(_ weekDays: Set<Int>) throws {
        guard !weekDays.isEmpty, weekDays.allSatisfy({ (1...7).contains($0) }) else {
            throw SchedulingPersistenceError.invalidWeekDays(weekDays)
        }
    }

    private func validateNoOverlap(_ weekDays: Set<Int>, excluding id: UUID?) throws {
        let overlap = templatesByID.values
            .filter { $0.id != id }
            .map { $0.weekDays.intersection(weekDays) }
            .reduce(into: Set<Int>()) { $0.formUnion($1) }
        guard overlap.isEmpty else {
            throw SchedulingPersistenceError.overlappingTemplateWeekDays(overlap)
        }
    }

    private func validateNewZones(
        _ zones: [Zone],
        excludingTemplateID: UUID?,
        excludingOverrideID: UUID?,
        existingZoneError: (UUID) -> SchedulingPersistenceError
    ) throws {
        var seenIDs = Set<UUID>()
        if let duplicate = zones.first(where: { !seenIDs.insert($0.id).inserted }) {
            throw SchedulingPersistenceError.duplicateZoneID(duplicate.id)
        }
        let otherZoneIDs = Set(
            templatesByID.values
                .filter { $0.id != excludingTemplateID }
                .flatMap(\.zones)
                .map(\.id)
            + overridesByID.values
                .filter { $0.id != excludingOverrideID }
                .flatMap(\.zones)
                .map(\.id)
        )
        if let invalid = zones.first(where: { otherZoneIDs.contains($0.id) }) {
            throw existingZoneError(invalid.id)
        }
    }

    private func normalized(_ templateOverride: TemplateOverrideData) -> TemplateOverrideData {
        TemplateOverrideData(
            id: templateOverride.id,
            name: templateOverride.name,
            createdAt: templateOverride.createdAt,
            dateOfDay: LocalDateKey.startOfDay(for: templateOverride.dateOfDay),
            zones: templateOverride.zones
        )
    }
}

public struct InMemoryZoneDataSource: LocalZoneDataSource {
    private let storage: InMemoryZoneStorage

    public init(storage: InMemoryZoneStorage) {
        self.storage = storage
    }

    public func validateOwnership() async throws {
        try await storage.validateOwnership()
    }

    public func updateZone(_ zone: Zone) async throws {
        try await storage.updateZone(zone)
    }
}

public struct InMemoryTemplateDataSource: LocalTemplateDataSource {
    private let storage: InMemoryZoneStorage

    public init(storage: InMemoryZoneStorage) {
        self.storage = storage
    }

    public func fetchTemplates() async -> [TemplateData] {
        await storage.fetchTemplates()
    }

    public func fetchTemplate(forWeekDay weekDay: Int) async throws -> TemplateData? {
        try await storage.fetchTemplate(forWeekDay: weekDay)
    }

    public func addTemplate(_ template: TemplateData) async throws {
        try await storage.addTemplate(template)
    }

    public func updateTemplate(_ template: TemplateData) async throws {
        try await storage.updateTemplate(template)
    }

    public func deleteTemplate(id: UUID) async {
        await storage.deleteTemplate(id: id)
    }

    public func deleteAllTemplates() async {
        await storage.deleteAllTemplates()
    }
}

public struct InMemoryTemplateOverrideDataSource: LocalTemplateOverrideDataSource {
    private let storage: InMemoryZoneStorage

    public init(storage: InMemoryZoneStorage) {
        self.storage = storage
    }

    public func fetchTemplateOverrides() async -> [TemplateOverrideData] {
        await storage.fetchTemplateOverrides()
    }

    public func fetchTemplateOverride(for date: Date) async throws -> TemplateOverrideData? {
        try await storage.fetchTemplateOverride(for: date)
    }

    public func addTemplateOverride(_ templateOverride: TemplateOverrideData) async throws {
        try await storage.addTemplateOverride(templateOverride)
    }

    public func updateTemplateOverride(_ templateOverride: TemplateOverrideData) async throws {
        try await storage.updateTemplateOverride(templateOverride)
    }

    public func deleteTemplateOverride(id: UUID) async {
        await storage.deleteTemplateOverride(id: id)
    }

    public func deleteAllTemplateOverrides() async {
        await storage.deleteAllTemplateOverrides()
    }
}

public struct InMemorySchedulingDataSources: Sendable {
    public let task: InMemoryTaskDataSource
    public let goal: InMemoryGoalDataSource
    public let session: InMemorySessionDataSource
    public let zone: InMemoryZoneDataSource
    public let template: InMemoryTemplateDataSource
    public let templateOverride: InMemoryTemplateOverrideDataSource

    public init(data: SchedulingMockData = .preview) {
        let zoneStorage = InMemoryZoneStorage(
            templates: data.templates,
            templateOverrides: data.templateOverrides
        )
        task = InMemoryTaskDataSource(tasks: data.tasks)
        goal = InMemoryGoalDataSource(goals: data.goals)
        session = InMemorySessionDataSource(sessions: data.sessions)
        zone = InMemoryZoneDataSource(storage: zoneStorage)
        template = InMemoryTemplateDataSource(storage: zoneStorage)
        templateOverride = InMemoryTemplateOverrideDataSource(storage: zoneStorage)
    }
}
