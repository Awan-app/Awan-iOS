public enum GamificationError: Error, Equatable, Sendable {
    case alreadyClaimed
    case authenticationFailed
    case userNotFound
    case invalidWheelConfiguration
    case unavailable(String)

}
