import Foundation

public struct ObserveAuthenticationUseCase: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncStream<UserEntity?> {
        repository.observeAuthenticatedUser()
    }
}
