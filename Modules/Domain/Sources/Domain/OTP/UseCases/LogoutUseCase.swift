import Foundation

public struct LogoutUseCase: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func execute() async throws {
        try await repository.logout()
    }
}
