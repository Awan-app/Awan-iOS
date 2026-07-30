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
        try await localDataSource.upsertTemplate(
            HomeRemoteMapper.templateData(response)
        )
    }

    public func listTemplates() async throws -> [Template] {
        let responses = try await remoteDataSource.listTemplates()
        let localTemplates = try responses.map(HomeRemoteMapper.templateData)
        let templates = try responses.map(HomeRemoteMapper.template)
        try await localDataSource.replaceTemplates(localTemplates)
        return templates
    }

    public func updateBulkTemplate(id: UUID, zones: [ZoneWithoutId]) async throws -> Template {
        let zonePayloads = zones.map { zone in
            BulkUpdateZonesRequestDTO.ZonePayload(
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex
            )
        }

        let request = BulkUpdateZonesRequestDTO(zones: zonePayloads)

        _ = try await remoteDataSource.bulkUpdate(templateID: id, request: request)
        
        let templateResponse = try await remoteDataSource.getTemplate(templateID: id)
        let localTemplate = try HomeRemoteMapper.templateData(templateResponse)
        let template = try HomeRemoteMapper.template(templateResponse)
        try await localDataSource.upsertTemplate(localTemplate)
        return template
    }

    public func updateTemplate(id: UUID, name: String, daysOfWeek: [String]) async throws -> Template {
        let request = UpdateTemplateRequestDTO(name: name, daysOfWeek: daysOfWeek)
        let response = try await remoteDataSource.updateTemplate(templateID: id, request: request)
        let localTemplate = try HomeRemoteMapper.templateData(response)
        let template = try HomeRemoteMapper.template(response)
        try await localDataSource.upsertTemplate(localTemplate)
        return template
    }

    public func deleteTemplate(id: UUID) async throws {
        try await remoteDataSource.deleteTemplate(templateID: id)
        try await localDataSource.deleteTemplate(id: id)
    }
}
