import Combine
import Foundation

public protocol ZoneRepository: Sendable {
    func fetchZones(for date: Date) async throws -> [Zone]
    func observeZones(for date: Date) -> AnyPublisher<[Zone], Error>
    func updateZone(_ zone: Zone) async throws
}

public extension ZoneRepository {
    func observeZones(for date: Date) -> AnyPublisher<[Zone], Error> {
        AsyncValuePublisher.make { try await fetchZones(for: date) }
    }
}
