import Domain

public struct DefaultZoneRepository: ZoneRepository {
    private let localDataSource: any LocalZoneDataSource

    public init(localDataSource: any LocalZoneDataSource) {
        self.localDataSource = localDataSource
    }

    public func fetchZones() async throws -> [Zone] {
        let records = try await localDataSource.fetchZones()
        return try records.map { try $0.toDomain() }
    }

    public func updateZone(_ zone: Zone) async throws {
        try await localDataSource.updateZone(ZoneRecord(domain: zone))
    }

    public func resetZones() async throws {
        try await localDataSource.resetZones()
    }
}
