public protocol ZoneRepository: Sendable {
    func fetchZones() async throws -> [Zone]
}
