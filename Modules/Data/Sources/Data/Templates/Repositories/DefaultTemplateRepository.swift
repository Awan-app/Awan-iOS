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

    public func createTemplate(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template {
        let request = CreateTemplateRequestDTO(
            name: name,
            daysOfWeek: orderedRawDays(daysOfWeek),
            zones: try zones.map(createPayload)
        )

        do {
            let response = try await remoteDataSource.createTemplate(request: request)
            let localTemplate = try HomeRemoteMapper.templateData(response)
            let template = try HomeRemoteMapper.template(response)
            try await localDataSource.upsertTemplate(localTemplate)
            return template
        } catch {
            throw TemplateManagementErrorMapper.map(error)
        }
    }

    public func listTemplates() async throws -> [Template] {
        do {
            let responses = try await remoteDataSource.listTemplates()
            let localTemplates = try responses.map(HomeRemoteMapper.templateData)
            let templates = try responses.map(HomeRemoteMapper.template)
            try await localDataSource.replaceTemplates(localTemplates)
            return templates
        } catch {
            throw TemplateManagementErrorMapper.map(error)
        }
    }

    public func updateBulkTemplate(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> Template {
        let zonePayloads = try zones.map { zone in
            guard let categoryID = zone.category?.id else {
                throw TemplateManagementError.zoneCategoryRequired
            }
            return BulkUpdateZonesRequestDTO.ZonePayload(
                id: zone.id?.uuidString,
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex,
                categoryId: categoryID
            )
        }

        let request = BulkUpdateZonesRequestDTO(zones: zonePayloads)

        do {
            _ = try await remoteDataSource.bulkUpdate(templateID: id, request: request)
            let response = try await remoteDataSource.getTemplate(templateID: id)
            let localTemplate = try HomeRemoteMapper.templateData(response)
            let template = try HomeRemoteMapper.template(response)
            try await localDataSource.upsertTemplate(localTemplate)
            return template
        } catch {
            throw TemplateManagementErrorMapper.map(error)
        }
    }

    public func updateTemplate(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template {
        let request = UpdateTemplateRequestDTO(
            name: name,
            daysOfWeek: orderedRawDays(daysOfWeek)
        )
        do {
            let response = try await remoteDataSource.updateTemplate(templateID: id, request: request)
            let localTemplate = try HomeRemoteMapper.templateData(response)
            let template = try HomeRemoteMapper.template(response)
            try await localDataSource.upsertTemplate(localTemplate)
            return template
        } catch {
            throw TemplateManagementErrorMapper.map(error)
        }
    }

    public func deleteTemplate(id: UUID) async throws {
        do {
            try await remoteDataSource.deleteTemplate(templateID: id)
            try await localDataSource.deleteTemplate(id: id)
        } catch {
            throw TemplateManagementErrorMapper.map(error)
        }
    }

    private func createPayload(_ zone: Zone) throws -> CreateTemplateRequestDTO.ZonePayload {
        guard let categoryID = zone.category?.id else {
            throw TemplateManagementError.zoneCategoryRequired
        }
        return CreateTemplateRequestDTO.ZonePayload(
            name: zone.name,
            startTime: formatted(zone.startTime),
            endTime: formatted(zone.endTime),
            color: zone.color.hex,
            categoryId: categoryID
        )
    }

    private func orderedRawDays(_ days: Set<TemplateWeekday>) -> [String] {
        TemplateWeekday.allCases.filter(days.contains).map(\.rawValue)
    }

    private func formatted(_ time: LocalTime) -> String {
        String(format: "%02d:%02d:00", time.hour, time.minute)
    }
}
