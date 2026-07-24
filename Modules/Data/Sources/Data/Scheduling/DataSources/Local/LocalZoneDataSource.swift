import Domain
import Foundation

public protocol LocalZoneDataSource: Sendable {
    func validateOwnership() async throws
    func updateZone(_ zone: Zone) async throws
    func upsertZone(_ zone: Zone, templateID: UUID?, templateOverrideID: UUID?) async throws
}
