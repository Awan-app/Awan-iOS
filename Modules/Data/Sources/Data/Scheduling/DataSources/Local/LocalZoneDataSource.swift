public protocol LocalZoneDataSource: Sendable {
    func fetchZones() async throws -> [ZoneRecord]
    func updateZone(_ zone: ZoneRecord) async throws
    func resetZones() async throws
}
