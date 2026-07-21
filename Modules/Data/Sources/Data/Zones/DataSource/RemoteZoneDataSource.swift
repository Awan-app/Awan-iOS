//
//  RemoteZoneDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public final class RemoteZoneDataSource: RemoteZoneDataSourceProtocol {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getZone(zoneId: UUID) async throws -> ZoneResponseDTO {
        try await networkService.request(ZoneEndpoint.getZone(zoneId: zoneId))
    }

    public func getZoneSessions(zoneId: UUID) async throws -> [SessionResponseDTO] {
        try await networkService.request(ZoneEndpoint.getZoneSessions(zoneId: zoneId))
    }

    public func getZonesByDate(date: String) async throws -> [ZoneResponseDTO] {
        try await networkService.request(ZoneEndpoint.getZonesByDate(date: date))
    }

    public func updateZone(zoneId: UUID, request: UpdateZoneRequestDTO) async throws -> ZoneResponseDTO {
        try await networkService.request(ZoneEndpoint.updateZone(zoneId: zoneId, request: request))
    }

    public func deleteZone(zoneId: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(ZoneEndpoint.deleteZone(zoneId: zoneId))
    }
}
