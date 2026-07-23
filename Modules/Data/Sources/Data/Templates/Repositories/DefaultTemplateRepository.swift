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
        
        // 2. If remote succeeds, map and save locally
        let localTemplate = TemplateData(
            id: response.id,
            name: "Weekly Zones",
            createdAt: Date(),
            weekDays: Set([0,1,2,3,4,5,6]),
            zones: zones
        )

        try await localDataSource.addTemplate(localTemplate)
    }
}
