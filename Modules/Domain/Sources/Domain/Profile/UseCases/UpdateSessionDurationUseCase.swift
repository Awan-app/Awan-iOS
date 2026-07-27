import Foundation

public protocol UpdateSessionDurationUseCase: Sendable {
    func execute(_ durationMinutes: Int) async throws -> UserProfile
}

public struct DefaultUpdateSessionDurationUseCase: UpdateSessionDurationUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute(_ durationMinutes: Int) async throws -> UserProfile {
        try await repository.updateSessionDuration(durationMinutes)
    }
}
