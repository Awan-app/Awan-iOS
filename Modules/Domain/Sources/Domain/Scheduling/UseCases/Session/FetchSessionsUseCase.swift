import Combine
import Foundation

public protocol FetchSessionsUseCase: Sendable {
    func execute(for date: Date) async throws -> [Session]
    func observe(for date: Date) -> AnyPublisher<[Session], Error>
}

public extension FetchSessionsUseCase {
    func observe(for date: Date) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { try await execute(for: date) }
    }
}

public struct DefaultFetchSessionsUseCase: FetchSessionsUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(for date: Date) async throws -> [Session] {
        try await repository.fetchSessions(for: date)
    }

    public func observe(for date: Date) -> AnyPublisher<[Session], Error> {
        repository.observeSessions(for: date)
    }
}
