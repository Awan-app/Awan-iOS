//
//  RemoteZoneDataSourceProtocol.swift
//  Data
//

import Foundation

public protocol RemoteZoneDataSourceProtocol: Sendable {
    func getZone(zoneId: UUID) async throws -> ZoneResponseDTO
    func getZoneSessions(zoneId: UUID) async throws -> [SessionResponseDTO]
    func getZonesByDate(date: String) async throws -> [ZoneResponseDTO]
    func updateZone(zoneId: UUID, request: UpdateZoneRequestDTO) async throws -> ZoneResponseDTO
    func deleteZone(zoneId: UUID) async throws
}
