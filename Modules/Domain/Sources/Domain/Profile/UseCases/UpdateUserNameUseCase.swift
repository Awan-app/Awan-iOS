import Foundation

public protocol UpdateUserProfileUseCase: Sendable {
    func execute(firstName: String?, lastName: String?, birthDate: String?) async throws
}

public struct DefaultUpdateUserProfileUseCase: UpdateUserProfileUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute(firstName: String?, lastName: String?, birthDate: String?) async throws {
        try await repository.updateProfile(firstName: firstName, lastName: lastName, birthDate: birthDate)
    }
}
