import Foundation

public struct UserPreferences: Equatable, Sendable {
    public let timezone: String
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int
    public let wakeupTime: LocalTime
    public let sleepTime: LocalTime

    public init(
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: LocalTime,
        sleepTime: LocalTime
    ) {
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }
}

public struct UserProfile: Equatable, Sendable {
    public let id: UUID
    public let email: String
    public let firstName: String
    public let lastName: String
    public let birthDate: BirthDate
    public let points: Int
    public let streak: Int
    public let maxStreak: Int
    public let preferences: UserPreferences

    public init(
        id: UUID,
        email: String,
        firstName: String,
        lastName: String,
        birthDate: BirthDate,
        points: Int,
        streak: Int,
        maxStreak: Int,
        preferences: UserPreferences
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
