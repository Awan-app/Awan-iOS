public enum OnboardingInputError: Error, Equatable, Sendable {
    case blankFirstName
    case blankLastName
    case invalidBirthDate
    case blankTimezone
    case invalidTimezone(String)
    case negativePreferredSessionDuration(Int)
    case negativeBufferBetweenSessions(Int)
    case invalidWakeupTime
    case invalidSleepTime
}

public struct OnboardingFieldValidationError: Equatable, Sendable {
    public let field: String
    public let message: String

    public init(field: String, message: String) {
        self.field = field
        self.message = message
    }
}

public enum OnboardingError: Error, Equatable, Sendable {
    case validationFailed([OnboardingFieldValidationError])
    case invalidTimezone
    case alreadyCompleted
    case networkFailure
    case invalidResponse
    case server(message: String)
}
