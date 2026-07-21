//
//  File.swift
//  Data
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Foundation
import AwaNetwork

public final class RemoteTemplateOverrideDataSource: RemoteTemplateOverrideDataSourceProtocol {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func createOverride(request: CreateTemplateOverrideRequestDTO) async throws -> TemplateOverrideResponseDTO {
        try await networkService.request(TemplateOverrideEndpoint.createOverride(request))
    }

    public func listOverrides() async throws -> [TemplateOverrideResponseDTO] {
        try await networkService.request(TemplateOverrideEndpoint.listOverrides)
    }

    public func getOverride(overrideId: UUID) async throws -> TemplateOverrideResponseDTO {
        try await networkService.request(TemplateOverrideEndpoint.getOverride(overrideId: overrideId))
    }

    public func updateOverride(overrideId: UUID, request: UpdateTemplateOverrideRequestDTO) async throws -> TemplateOverrideResponseDTO {
        try await networkService.request(TemplateOverrideEndpoint.updateOverride(overrideId: overrideId, request))
    }

    public func deleteOverride(overrideId: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(
            TemplateOverrideEndpoint.deleteOverride(overrideId: overrideId)
        )
    }

    public func addZone(overrideId: UUID, request: AddZoneRequestDTO) async throws -> ZoneResponseDTO {
        try await networkService.request(TemplateOverrideEndpoint.addZone(overrideId: overrideId, request))
    }

    public func getZones(overrideId: UUID) async throws -> [ZoneResponseDTO] {
        try await networkService.request(TemplateOverrideEndpoint.getZones(overrideId: overrideId))
    }
}
