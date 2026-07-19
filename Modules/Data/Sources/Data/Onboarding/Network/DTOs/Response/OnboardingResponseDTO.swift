import Foundation

public struct OnboardingPreferencesResponseDTO: Decodable, Sendable {
    public let timezone: String
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int
    public let wakeupTime: String
    public let sleepTime: String

    public init(
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: String,
        sleepTime: String
    ) {
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }
}

public struct OnboardingResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let email: String
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let points: Int
    public let streak: Int
    public let maxStreak: Int
    public let preferences: OnboardingPreferencesResponseDTO

    public init(
        id: UUID,
        email: String,
        firstName: String,
        lastName: String,
        birthDate: String,
        points: Int,
        streak: Int,
        maxStreak: Int,
        preferences: OnboardingPreferencesResponseDTO
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.points = points
        self.streak = streak
        self.maxStreak = maxStreak
        self.preferences = preferences
    }
}
