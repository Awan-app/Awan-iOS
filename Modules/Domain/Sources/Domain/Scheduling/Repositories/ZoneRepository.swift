import Foundation

public protocol ZoneRepository: Sendable {
    func fetchZones(for date: Date) async throws -> [Zone]
    func updateZone(_ zone: Zone) async throws
}
