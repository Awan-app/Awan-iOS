import Foundation

public protocol UpdateUserNameUseCase: Sendable {
    func execute(firstName: String, lastName: String) async throws
}

public struct DefaultUpdateUserNameUseCase: UpdateUserNameUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute(firstName: String, lastName: String) async throws {
        try await repository.updateName(firstName: firstName, lastName: lastName)
    }
}
