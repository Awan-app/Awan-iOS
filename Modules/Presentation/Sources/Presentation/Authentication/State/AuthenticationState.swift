import Domain
import Observation

public enum AuthenticationStatus: Equatable, Sendable {
    case checking
    case authenticated(UserEntity)
    case unauthenticated
}

@Observable
@MainActor
public final class AuthenticationState {
    public private(set) var status: AuthenticationStatus = .checking

    private let observeAuthenticationUseCase: ObserveAuthenticationUseCase
    private var observationTask: Task<Void, Never>?

    public init(observeAuthenticationUseCase: ObserveAuthenticationUseCase) {
        self.observeAuthenticationUseCase = observeAuthenticationUseCase
    }

    public func start() {
        guard observationTask == nil else { return }

        observationTask = Task { [observeAuthenticationUseCase] in
            for await user in observeAuthenticationUseCase.execute() {
                guard !Task.isCancelled else { return }
                status = user.map(AuthenticationStatus.authenticated) ?? .unauthenticated
            }
        }
    }
}
