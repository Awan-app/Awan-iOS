import Domain
import Foundation

public protocol LocalZoneDataSource: Sendable {
    func validateOwnership() async throws
    func removeOrphanedZones() async throws
    func updateZone(_ zone: Zone) async throws
}
