import Combine

public protocol UserProfileRepository: Sendable {
    func fetchCurrentUser() async throws -> UserProfile
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error>
    func updateName(firstName: String, lastName: String) async throws
}

public extension UserProfileRepository {
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error> {
        AsyncValuePublisher.make { try await fetchCurrentUser() }
    }
}
