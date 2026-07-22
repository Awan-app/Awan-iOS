import Combine

public protocol GetUserProfileUseCase: Sendable {
    func execute() async throws -> UserProfile
    func observe() -> AnyPublisher<UserProfile, Error>
}

public extension GetUserProfileUseCase {
    func observe() -> AnyPublisher<UserProfile, Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultGetUserProfileUseCase: GetUserProfileUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute() async throws -> UserProfile {
        try await repository.fetchCurrentUser()
    }

    public func observe() -> AnyPublisher<UserProfile, Error> {
        repository.observeCurrentUser()
    }
}
