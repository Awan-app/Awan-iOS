//
//  File.swift
//  Data
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Foundation
import AwaNetwork

public protocol RemoteTemplateOverrideDataSourceProtocol: Sendable {
    func createOverride(request: CreateTemplateOverrideRequestDTO) async throws -> TemplateOverrideResponseDTO
    func listOverrides() async throws -> [TemplateOverrideResponseDTO]
    func getOverride(overrideId: UUID) async throws -> TemplateOverrideResponseDTO
    func updateOverride(overrideId: UUID, request: UpdateTemplateOverrideRequestDTO) async throws -> TemplateOverrideResponseDTO
    func deleteOverride(overrideId: UUID) async throws
    func addZone(overrideId: UUID, request: AddZoneRequestDTO) async throws -> ZoneResponseDTO
    func getZones(overrideId: UUID) async throws -> [ZoneResponseDTO]
}
