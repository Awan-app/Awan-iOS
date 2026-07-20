import AwaNetwork
import Domain

enum OnboardingErrorMapper {
    static func map(_ error: any Error) -> OnboardingError {
        if let onboardingError = error as? OnboardingError {
            return onboardingError
        }
        guard let networkError = error as? NetworkError else {
            return .server(message: error.localizedDescription)
        }
        return map(networkError)
    }

    private static func map(_ error: NetworkError) -> OnboardingError {
        switch error {
        case .httpError(_, let apiError):
            guard let apiError else {
                return .server(message: error.localizedDescription)
            }

            switch apiError.errorCode {
            case .validationError:
                let fieldErrors = apiError.info?.validationErrors.map {
                    OnboardingFieldValidationError(
                        field: $0.field,
                        message: $0.message
                    )
                } ?? []
                return .validationFailed(fieldErrors)
            case .invalidTimezone:
                return .invalidTimezone
            case .onboardingAlreadyCompleted:
                return .alreadyCompleted
            default:
                return .server(message: apiError.message)
            }
        case .underlying:
            return .networkFailure
        case .decodingFailed, .noContent:
            return .invalidResponse
        case .invalidURL, .encodingFailed:
            return .server(message: error.localizedDescription)
        }
    }
}
