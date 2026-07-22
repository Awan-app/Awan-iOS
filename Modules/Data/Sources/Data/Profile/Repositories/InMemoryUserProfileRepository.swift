import Domain
import Foundation

public actor InMemoryUserProfileRepository: UserProfileRepository {
    private var profile: UserProfile

    public init(profile: UserProfile) {
        self.profile = profile
    }

    public func fetchCurrentUser() -> UserProfile {
        profile
    }
}

public enum UserProfileMockData {
    public static var preview: UserProfile {
        do {
            return UserProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000070") ?? UUID(),
                email: "sam@awan.app",
                firstName: "Sam",
                lastName: "Nour",
                birthDate: try BirthDate(year: 1998, month: 7, day: 22),
                points: 1_285,
                streak: 8,
                maxStreak: 14,
                preferences: UserPreferences(
                    timezone: TimeZone.current.identifier,
                    preferredSessionDuration: 50,
                    bufferBetweenSessions: 10,
                    wakeupTime: try LocalTime(hour: 7, minute: 0),
                    sleepTime: try LocalTime(hour: 1, minute: 0)
                )
            )
        } catch {
            preconditionFailure("Invalid preview user profile: \(error)")
        }
    }
}
