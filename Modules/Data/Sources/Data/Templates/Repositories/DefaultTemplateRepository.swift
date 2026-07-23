import Foundation
import Domain

public final class DefaultTemplateRepository: TemplateRepository, Sendable {
    private let remoteDataSource: any RemoteTemplateDataSourceProtocol
    private let localDataSource: any LocalTemplateDataSource

    public init(
        remoteDataSource: any RemoteTemplateDataSourceProtocol,
        localDataSource: any LocalTemplateDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func createWeeklyTemplate(zones: [Zone]) async throws {
        // Map Domain Zones to Remote DTOs
        let zonePayloads = zones.map { zone in
            CreateTemplateRequestDTO.ZonePayload(
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex
            )
        }

        let request = CreateTemplateRequestDTO(
            name: "Weekly Zones",
            daysOfWeek: [
                "MONDAY",
                "TUESDAY",
                "WEDNESDAY",
                "THURSDAY",
                "FRIDAY",
                "SATURDAY",
                "SUNDAY"
            ],
            zones: zonePayloads
        )

        // 1. Create Remotely
        let response = try await remoteDataSource.createTemplate(request: request)

        // 2. Cache the server-created aggregate so remote identifiers remain authoritative.
        let remoteZones = try response.zones.map(HomeRemoteMapper.zone)
        let localTemplate = TemplateData(
            id: response.id,
            name: response.name,
            createdAt: Date(),
            weekDays: Set([1,2,3,4,5,6,7]),
            zones: remoteZones
        )

        try await localDataSource.addTemplate(localTemplate)
    }

    public func listTemplates() async throws -> [Template] {
        let responses = try await remoteDataSource.listTemplates()
        return try responses.map(HomeRemoteMapper.template)
    }

    public func updateTemplate(id: UUID, zones: [Zone]) async throws -> Template {
        // Since UpdateTemplateRequestDTO does not support updating zones directly yet,
        // we might just update the template itself, or we would delete/recreate. 
        // For now, this is a placeholder for when the API supports zone updates.
        let request = UpdateTemplateRequestDTO(
            name: "Updated Template",
            daysOfWeek: ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        )

        let response = try await remoteDataSource.updateTemplate(templateID: id, request: request)
        return try HomeRemoteMapper.template(response)
    }
}
