import Combine
import Foundation

public protocol FetchZonesUseCase: Sendable {
    func execute(for date: Date) async throws -> [Zone]
    func observe(for date: Date) -> AnyPublisher<[Zone], Error>
}

public extension FetchZonesUseCase {
    func observe(for date: Date) -> AnyPublisher<[Zone], Error> {
        AsyncValuePublisher.make { try await execute(for: date) }
    }
}

public struct DefaultFetchZonesUseCase: FetchZonesUseCase {
    private let repository: any ZoneRepository

    public init(repository: any ZoneRepository) {
        self.repository = repository
    }

    public func execute(for date: Date) async throws -> [Zone] {
        try await repository.fetchZones(for: date)
    }

    public func observe(for date: Date) -> AnyPublisher<[Zone], Error> {
        repository.observeZones(for: date)
    }
}
