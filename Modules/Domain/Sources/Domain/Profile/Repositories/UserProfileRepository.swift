public protocol UserProfileRepository: Sendable {
    func fetchCurrentUser() async throws -> UserProfile
}
