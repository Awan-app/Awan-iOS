import Combine

public protocol UserProfileRepository: Sendable {
    func fetchCurrentUser() async throws -> UserProfile
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error>
    func updateSessionDuration(_ durationMinutes: Int) async throws -> UserProfile
    func updateTimezone(_ timezone: String) async throws -> UserProfile
}

public extension UserProfileRepository {
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error> {
        AsyncValuePublisher.make { try await fetchCurrentUser() }
    }
}
