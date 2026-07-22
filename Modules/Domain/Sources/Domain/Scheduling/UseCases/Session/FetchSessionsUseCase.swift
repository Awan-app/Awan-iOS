public protocol FetchSessionsUseCase: Sendable {
    func execute() async throws -> [Session]
}

public struct DefaultFetchSessionsUseCase: FetchSessionsUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Session] {
        try await repository.fetchSessions()
    }
}
