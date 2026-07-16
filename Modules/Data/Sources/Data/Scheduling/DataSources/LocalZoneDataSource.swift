public protocol LocalZoneDataSource: Sendable {
    func fetchZones() async throws -> [ZoneRecord]
}
