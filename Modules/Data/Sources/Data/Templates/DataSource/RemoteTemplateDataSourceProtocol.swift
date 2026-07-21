//
//  RemoteTemplateDataSource.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation
import AwaNetwork

public protocol RemoteTemplateDataSourceProtocol: Sendable {
    func createTemplate(request: CreateTemplateRequestDTO) async throws -> TemplateResponseDTO
    func listTemplates() async throws -> [TemplateResponseDTO]
    func getTemplate(templateID: UUID) async throws -> TemplateResponseDTO
    func updateTemplate(templateID: UUID, request: UpdateTemplateRequestDTO) async throws -> TemplateResponseDTO
    func deleteTemplate(templateID: UUID) async throws
    func addZone(templateID: UUID, request: AddZoneRequestDTO) async throws -> ZoneResponseDTO
    func getZones(templateID: UUID) async throws -> [ZoneResponseDTO]
}

public final class RemoteTemplateDataSource: RemoteTemplateDataSourceProtocol {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func createTemplate(request: CreateTemplateRequestDTO) async throws -> TemplateResponseDTO {
        try await networkService.request(TemplateEndpoint.createTemplate(request))
    }

    public func listTemplates() async throws -> [TemplateResponseDTO] {
        try await networkService.request(TemplateEndpoint.listTemplates)
    }

    public func getTemplate(templateID: UUID) async throws -> TemplateResponseDTO {
        try await networkService.request(TemplateEndpoint.getTemplate(templateID: templateID))
    }

    public func updateTemplate(templateID: UUID, request: UpdateTemplateRequestDTO) async throws -> TemplateResponseDTO {
        try await networkService.request(TemplateEndpoint.updateTemplate(templateID: templateID, request))
    }

    public func deleteTemplate(templateID: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(
            TemplateEndpoint.deleteTemplate(templateID: templateID)
        )
    }

    public func addZone(templateID: UUID, request: AddZoneRequestDTO) async throws -> ZoneResponseDTO {
        try await networkService.request(TemplateEndpoint.addZone(templateID: templateID, request))
    }

    public func getZones(templateID: UUID) async throws -> [ZoneResponseDTO] {
        try await networkService.request(TemplateEndpoint.getZones(templateID: templateID))
    }
}
