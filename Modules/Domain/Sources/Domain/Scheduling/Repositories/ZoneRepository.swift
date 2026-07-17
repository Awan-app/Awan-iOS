public protocol ZoneRepository: Sendable {
    func fetchZones() async throws -> [Zone]
    func updateZone(_ zone: Zone) async throws
    func resetZones() async throws
}
