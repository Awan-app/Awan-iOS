public protocol GetUserProfileUseCase: Sendable {
    func execute() async throws -> UserProfile
}

public struct DefaultGetUserProfileUseCase: GetUserProfileUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute() async throws -> UserProfile {
        try await repository.fetchCurrentUser()
    }
}
