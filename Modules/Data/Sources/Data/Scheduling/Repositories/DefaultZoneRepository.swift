import Combine
import Domain
import Foundation

public struct DefaultZoneRepository: ZoneRepository {
    private let zoneDataSource: any LocalZoneDataSource
    private let templateDataSource: any LocalTemplateDataSource
    private let templateOverrideDataSource: any LocalTemplateOverrideDataSource
    private let profileDataSource: any LocalUserProfileDataSource
    private let remoteTemplateDataSource: any RemoteTemplateDataSourceProtocol
    private let remoteTemplateOverrideDataSource:
        any RemoteTemplateOverrideDataSourceProtocol

    public init(
        zoneDataSource: any LocalZoneDataSource,
        templateDataSource: any LocalTemplateDataSource,
        templateOverrideDataSource: any LocalTemplateOverrideDataSource,
        profileDataSource: any LocalUserProfileDataSource,
        remoteTemplateDataSource: any RemoteTemplateDataSourceProtocol,
        remoteTemplateOverrideDataSource:
            any RemoteTemplateOverrideDataSourceProtocol
    ) {
        self.zoneDataSource = zoneDataSource
        self.templateDataSource = templateDataSource
        self.templateOverrideDataSource = templateOverrideDataSource
        self.profileDataSource = profileDataSource
        self.remoteTemplateDataSource = remoteTemplateDataSource
        self.remoteTemplateOverrideDataSource = remoteTemplateOverrideDataSource
    }

    public func fetchZones(for date: Date) async throws -> [Zone] {
        try await zoneDataSource.validateOwnership()
        let profile = try await profileDataSource.fetchProfile()
        let timeZoneID = profile?.preferences.timezone ?? TimeZone.current.identifier
        let dateKey = LocalDateKey.value(for: date, timeZoneID: timeZoneID)
        if let templateOverride = try await templateOverrideDataSource
            .fetchTemplateOverride(forDateKey: dateKey) {
            return templateOverride.zones
        }
        let weekDay = LocalDateKey.weekDay(for: date, timeZoneID: timeZoneID)
        return try await templateDataSource.fetchTemplate(forWeekDay: weekDay)?.zones ?? []
    }

    public func observeZones(for date: Date) -> AnyPublisher<[Zone], Error> {
        let cached = AsyncValuePublisher.make { try await fetchZones(for: date) }
            .catch { _ in Empty<[Zone], Error>() }
            .eraseToAnyPublisher()
        let remote = AsyncValuePublisher.make { try await loadRemoteZones(for: date) }
        return cached.append(remote).eraseToAnyPublisher()
    }

    private func loadRemoteZones(for date: Date) async throws -> [Zone] {
        async let templateResponses = remoteTemplateDataSource.listTemplates()
        async let templateOverrideResponses =
            remoteTemplateOverrideDataSource.listOverrides()

        let (templateDTOs, templateOverrideDTOs) = try await (
            templateResponses,
            templateOverrideResponses
        )
        let templates = try templateDTOs.map(HomeRemoteMapper.templateData)
        let templateOverrides = try templateOverrideDTOs.map(
            HomeRemoteMapper.templateOverrideData
        )

        try await templateDataSource.replaceTemplates(templates)
        try await templateOverrideDataSource.replaceTemplateOverrides(
            templateOverrides
        )
        try await zoneDataSource.removeOrphanedZones()
        return try await fetchZones(for: date)
    }

    public func updateZone(_ zone: Zone) async throws {
        try await zoneDataSource.updateZone(zone)
    }
}
