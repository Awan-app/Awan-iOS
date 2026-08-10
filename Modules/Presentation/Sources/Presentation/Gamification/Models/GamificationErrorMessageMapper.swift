import Common
import Domain

enum GamificationErrorMessageMapper {
    static func message(for error: any Error) -> String {
        guard let error = error as? GamificationError else {
            return L10n.DailyWheel.errorUnavailable
        }

        switch error {
        case .alreadyClaimed:
            return L10n.DailyWheel.errorAlreadyClaimed
        case .authenticationFailed:
            return L10n.DailyWheel.errorAuthenticationFailed
        case .userNotFound:
            return L10n.DailyWheel.errorUserNotFound
        case .invalidWheelConfiguration:
            return L10n.DailyWheel.errorInvalidConfiguration
        case .unavailable:
            return L10n.DailyWheel.errorUnavailable
        }
    }
}
