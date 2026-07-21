import Domain

public protocol LocalZoneDataSource: Sendable {
    func validateOwnership() async throws
    func updateZone(_ zone: Zone) async throws
}
