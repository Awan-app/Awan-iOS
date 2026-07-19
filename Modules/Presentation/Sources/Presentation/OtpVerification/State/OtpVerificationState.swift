public enum OtpVerificationState: Equatable, Sendable {
    case idle
    case verifying
    case success
    case failure(AuthenticationErrorState)

    public var error: AuthenticationErrorState? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

    public var isFailure: Bool {
        error != nil
    }
}
