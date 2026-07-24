import Combine
import Domain
import Foundation

public struct DefaultZoneRepository: ZoneRepository {
    private let zoneDataSource: any LocalZoneDataSource
    private let templateDataSource: any LocalTemplateDataSource
    private let templateOverrideDataSource: any LocalTemplateOverrideDataSource
    private let profileDataSource: any LocalUserProfileDataSource
    private let remoteDataSource: any RemoteZoneDataSourceProtocol

    public init(
        zoneDataSource: any LocalZoneDataSource,
        templateDataSource: any LocalTemplateDataSource,
        templateOverrideDataSource: any LocalTemplateOverrideDataSource,
        profileDataSource: any LocalUserProfileDataSource,
        remoteDataSource: any RemoteZoneDataSourceProtocol
    ) {
        self.zoneDataSource = zoneDataSource
        self.templateDataSource = templateDataSource
        self.templateOverrideDataSource = templateOverrideDataSource
        self.profileDataSource = profileDataSource
        self.remoteDataSource = remoteDataSource
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

    public func observeZones(for date: Date) -> AnyPublisher<[Zone], Error> {
        let cached = AsyncValuePublisher.make { try await fetchZones(for: date) }
        let remote = AsyncValuePublisher.make { try await loadRemoteZones(for: date) }
        return cached.append(remote).eraseToAnyPublisher()
    }

    private func loadRemoteZones(for date: Date) async throws -> [Zone] {
        guard let profile = try await profileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        let dateKey = LocalDateKey.value(
            for: date,
            timeZoneID: profile.preferences.timezone
        )
        let dtos = try await remoteDataSource.getZonesByDate(date: dateKey)
        var zones: [Zone] = []
        for dto in dtos {
            let zone = try HomeRemoteMapper.zone(dto)
            zones.append(zone)
            try await zoneDataSource.upsertZone(
                zone,
                templateID: dto.templateId,
                templateOverrideID: dto.templateOverrideId
            )
        }
        return zones
    }

    public func updateZone(_ zone: Zone) async throws {
        try await zoneDataSource.updateZone(zone)
    }
}
