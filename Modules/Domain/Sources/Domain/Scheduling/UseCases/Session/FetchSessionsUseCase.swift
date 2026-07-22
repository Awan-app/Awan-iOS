import Combine
import Foundation

public protocol FetchSessionsUseCase: Sendable {
    func execute() async throws -> [Session]
    func observe(taskIDs: [UUID]) -> AnyPublisher<[Session], Error>
}

public extension FetchSessionsUseCase {
    func observe(taskIDs: [UUID]) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make {
            try await execute().filter { taskIDs.contains($0.taskID) }
        }
    }
}

public struct DefaultFetchSessionsUseCase: FetchSessionsUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Session] {
        try await repository.fetchSessions()
    }

    public func observe(taskIDs: [UUID]) -> AnyPublisher<[Session], Error> {
        repository.observeSessions(taskIDs: taskIDs)
    }
}
