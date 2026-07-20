import Domain
import Foundation

public struct DefaultZoneRepository: ZoneRepository {
    private let zoneDataSource: any LocalZoneDataSource
    private let templateDataSource: any LocalTemplateDataSource
    private let templateOverrideDataSource: any LocalTemplateOverrideDataSource

    public init(
        zoneDataSource: any LocalZoneDataSource,
        templateDataSource: any LocalTemplateDataSource,
        templateOverrideDataSource: any LocalTemplateOverrideDataSource
    ) {
        self.zoneDataSource = zoneDataSource
        self.templateDataSource = templateDataSource
        self.templateOverrideDataSource = templateOverrideDataSource
    }

    public func fetchZones(for date: Date) async throws -> [Zone] {
        try await zoneDataSource.validateOwnership()
        if let templateOverride = try await templateOverrideDataSource
            .fetchTemplateOverride(for: date) {
            return templateOverride.zones
        }
        let weekDay = LocalDateKey.weekDay(for: date)
        return try await templateDataSource.fetchTemplate(forWeekDay: weekDay)?.zones ?? []
    }

    public func updateZone(_ zone: Zone) async throws {
        try await zoneDataSource.updateZone(zone)
    }
}
