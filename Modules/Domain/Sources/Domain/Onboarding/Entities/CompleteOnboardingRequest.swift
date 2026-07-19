import Foundation

public struct CompleteOnboardingRequest: Equatable, Sendable {
    public let firstName: String
    public let lastName: String
    public let birthDate: BirthDate
    public let timezone: String
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int
    public let wakeupTime: LocalTime
    public let sleepTime: LocalTime

    public init(
        firstName: String,
        lastName: String,
        birthDate: BirthDate,
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: LocalTime,
        sleepTime: LocalTime
    ) throws {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OnboardingInputError.blankFirstName
        }
        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OnboardingInputError.blankLastName
        }
        guard !timezone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OnboardingInputError.blankTimezone
        }
        guard TimeZone(identifier: timezone) != nil else {
            throw OnboardingInputError.invalidTimezone(timezone)
        }
        guard preferredSessionDuration >= 0 else {
            throw OnboardingInputError.negativePreferredSessionDuration(
                preferredSessionDuration
            )
        }
        guard bufferBetweenSessions >= 0 else {
            throw OnboardingInputError.negativeBufferBetweenSessions(
                bufferBetweenSessions
            )
        }

        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }
}
