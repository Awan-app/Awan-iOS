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
        case .insufficientPoints:
            return L10n.Marketplace.needMorePts
        case .itemNotFound:
            return L10n.DailyWheel.errorUnavailable
        case .itemNotOwned:
            return L10n.Marketplace.itemNotOwned
        case .typeMismatch:
            return L10n.DailyWheel.errorUnavailable
        case let .unknown(message):
            return message.isEmpty ? L10n.DailyWheel.errorUnavailable : message
        case let .unavailable(message):
            return message.isEmpty ? L10n.DailyWheel.errorUnavailable : message
        }
    }
}
