import Domain

public enum AuthenticationErrorState: Equatable, Sendable {
    case inline(message: String)
    case network

    public init(error: Error) {
        if let authError = error as? AuthError,
           case .networkFailure = authError {
            self = .network
        } else {
            self = .inline(message: error.localizedDescription)
        }
    }
}
