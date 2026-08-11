import Foundation

public protocol UpdateTimezoneUseCase: Sendable {
    func execute(_ timezone: String) async throws -> UserProfile
}

public struct DefaultUpdateTimezoneUseCase: UpdateTimezoneUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute(_ timezone: String) async throws -> UserProfile {
        try await repository.updateTimezone(timezone)
    }
}
