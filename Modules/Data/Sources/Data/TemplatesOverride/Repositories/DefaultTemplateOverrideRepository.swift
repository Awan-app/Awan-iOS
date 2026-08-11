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

    public func createTemplateOverride(
        name: String,
        dateOfDay: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride {
        let zoneDTOs = try zones?.map { zone in
            guard let categoryID = zone.category?.id else {
                throw TemplateManagementError.zoneCategoryRequired
            }
            return AddZoneRequestDTO(
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex,
                categoryId: categoryID
            )
        }
        let request = CreateTemplateOverrideRequestDTO(
            name: name,
            dateOfDay: dateOfDay.iso8601,
            zones: zoneDTOs
        )
        do {
            let response = try await remoteDataSource.createOverride(request: request)
            let localData = try HomeRemoteMapper.templateOverrideData(response)
            try await localDataSource.addTemplateOverride(localData)
            return try HomeRemoteMapper.templateOverride(response)
        } catch {
            throw TemplateManagementErrorMapper.map(error, overrideOperation: true)
        }
    }

    public func listTemplateOverrides() async throws -> [TemplateOverride] {
        do {
            let responses = try await remoteDataSource.listOverrides()
            let localOverrides = try responses.map(HomeRemoteMapper.templateOverrideData)
            let overrides = try responses.map(HomeRemoteMapper.templateOverride)
            try await localDataSource.replaceTemplateOverrides(localOverrides)
            return overrides
        } catch {
            throw TemplateManagementErrorMapper.map(error, overrideOperation: true)
        }
    }

    public func updateTemplateOverride(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate
    ) async throws -> TemplateOverride {
        let request = UpdateTemplateOverrideRequestDTO(
            name: name,
            dateOfDay: dateOfDay.iso8601
        )
        do {
            let response = try await remoteDataSource.updateOverride(overrideId: id, request: request)
            let localData = try HomeRemoteMapper.templateOverrideData(response)
            try await localDataSource.updateTemplateOverride(localData)
            return try HomeRemoteMapper.templateOverride(response)
        } catch {
            throw TemplateManagementErrorMapper.map(error, overrideOperation: true)
        }
    }

    public func updateBulkTemplateOverride(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> TemplateOverride {
        let zonePayloads = try zones.map { zone in
            guard let categoryID = zone.category?.id else {
                throw TemplateManagementError.zoneCategoryRequired
            }
            return BulkUpdateOverrideZonesRequestDTO.ZonePayload(
                id: zone.id?.uuidString,
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex,
                categoryId: categoryID
            )
        }

        let request = BulkUpdateOverrideZonesRequestDTO(zones: zonePayloads)

        do {
            _ = try await remoteDataSource.updateBulkTemplateOverride(overrideId: id, request: request)
            let response = try await remoteDataSource.getOverride(overrideId: id)
            let localData = try HomeRemoteMapper.templateOverrideData(response)
            try await localDataSource.updateTemplateOverride(localData)
            return try HomeRemoteMapper.templateOverride(response)
        } catch {
            throw TemplateManagementErrorMapper.map(error, overrideOperation: true)
        }
    }
    
    public func deleteTemplateOverride(id: UUID) async throws {
        do {
            try await remoteDataSource.deleteOverride(overrideId: id)
            try await localDataSource.deleteTemplateOverride(id: id)
        } catch {
            throw TemplateManagementErrorMapper.map(error, overrideOperation: true)
        }
    }
}
