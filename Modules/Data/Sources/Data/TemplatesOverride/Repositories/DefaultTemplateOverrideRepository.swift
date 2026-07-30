import Foundation
import Domain

public final class DefaultTemplateOverrideRepository: TemplateOverrideRepository, Sendable {
    private let remoteDataSource: any RemoteTemplateOverrideDataSourceProtocol
    private let localDataSource: any LocalTemplateOverrideDataSource

    public init(
        remoteDataSource: any RemoteTemplateOverrideDataSourceProtocol,
        localDataSource: any LocalTemplateOverrideDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func createTemplateOverride(name: String?, dateOfDay: String, zones: [Zone]?) async throws -> TemplateOverride {
        let zoneDTOs = zones?.map { zone in
            AddZoneRequestDTO(
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex
            )
        }
        let request = CreateTemplateOverrideRequestDTO(name: name, dateOfDay: dateOfDay, zones: zoneDTOs)
        let response = try await remoteDataSource.createOverride(request: request)
        let localData = try HomeRemoteMapper.templateOverrideData(response)
        try await localDataSource.addTemplateOverride(localData)
        return try HomeRemoteMapper.templateOverride(response)
    }

    public func updateTemplateOverride(id: UUID, name: String?, dateOfDay: String) async throws -> TemplateOverride {
        let request = UpdateTemplateOverrideRequestDTO(name: name, dateOfDay: dateOfDay)
        let response = try await remoteDataSource.updateOverride(overrideId: id, request: request)
        let localData = try HomeRemoteMapper.templateOverrideData(response)
        try await localDataSource.updateTemplateOverride(localData)
        return try HomeRemoteMapper.templateOverride(response)
    }

    public func updateBulkTemplateOverride(id: UUID, zones: [Zone]) async throws -> [Zone] {
        let zonePayloads = zones.map { zone in
            BulkUpdateOverrideZonesRequestDTO.ZonePayload(
                id: zone.id.uuidString,
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex
            )
        }

        let request = BulkUpdateOverrideZonesRequestDTO(zones: zonePayloads)

        let responses = try await remoteDataSource.updateBulkTemplateOverride(overrideId: id, request: request)
        
        // Ensure local cache gets updated if necessary (skipped if local data source does not have bulk save yet)
        
        return try responses.compactMap { try HomeRemoteMapper.zone($0) }
    }
    
    public func deleteTemplateOverride(id: UUID) async throws {
        try await remoteDataSource.deleteOverride(overrideId: id)
        try await localDataSource.deleteTemplateOverride(id: id)
    }
}
