import Foundation
import Domain

public final class DefaultTemplateOverrideRepository: TemplateOverrideRepository, Sendable {
    private let remoteDataSource: any RemoteTemplateOverrideDataSourceProtocol

    public init(remoteDataSource: any RemoteTemplateOverrideDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func updateBulkTemplateOverride(id: UUID, zones: [Zone]) async throws -> [Zone] {
        let zonePayloads = zones.map { zone in
            BulkUpdateOverrideZonesRequestDTO.ZonePayload(
                id: zone.id.uuidString,
                name: zone.name,
                startTime: String(format: "%02d:%02d:00", zone.startTime.hour, zone.startTime.minute),
                endTime: String(format: "%02d:%02d:00", zone.endTime.hour, zone.endTime.minute),
                color: zone.color.hex
            )
        }

        let request = BulkUpdateOverrideZonesRequestDTO(zones: zonePayloads)

        let responses = try await remoteDataSource.updateBulkTemplateOverride(overrideId: id, request: request)
        
        return try responses.compactMap { try HomeRemoteMapper.zone($0) }
    }
}
