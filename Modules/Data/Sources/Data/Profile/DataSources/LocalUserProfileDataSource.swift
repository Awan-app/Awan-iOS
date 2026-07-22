import Domain
import SwiftData

public protocol LocalUserProfileDataSource: Sendable {
    func fetchProfile() async throws -> UserProfile?
    func replaceProfile(_ profile: UserProfile) async throws
}

@ModelActor
public actor SwiftDataUserProfileDataSource: LocalUserProfileDataSource {
    public func fetchProfile() throws -> UserProfile? {
        guard let model = try modelContext.fetch(FetchDescriptor<UserProfileModel>()).first else {
            return nil
        }
        return UserProfile(
            id: model.id,
            email: model.email,
            firstName: model.firstName,
            lastName: model.lastName,
            birthDate: try BirthDate(
                year: model.birthYear,
                month: model.birthMonth,
                day: model.birthDay
            ),
            points: model.points,
            streak: model.streak,
            maxStreak: model.maxStreak,
            preferences: UserPreferences(
                timezone: model.timezone,
                preferredSessionDuration: model.preferredSessionDuration,
                bufferBetweenSessions: model.bufferBetweenSessions,
                wakeupTime: try LocalTime(hour: model.wakeupHour, minute: model.wakeupMinute),
                sleepTime: try LocalTime(hour: model.sleepHour, minute: model.sleepMinute)
            )
        )
    }

    public func replaceProfile(_ profile: UserProfile) throws {
        for model in try modelContext.fetch(FetchDescriptor<UserProfileModel>()) {
            modelContext.delete(model)
        }
        modelContext.insert(
            UserProfileModel(
                id: profile.id,
                email: profile.email,
                firstName: profile.firstName,
                lastName: profile.lastName,
                birthYear: profile.birthDate.year,
                birthMonth: profile.birthDate.month,
                birthDay: profile.birthDate.day,
                points: profile.points,
                streak: profile.streak,
                maxStreak: profile.maxStreak,
                timezone: profile.preferences.timezone,
                preferredSessionDuration: profile.preferences.preferredSessionDuration,
                bufferBetweenSessions: profile.preferences.bufferBetweenSessions,
                wakeupHour: profile.preferences.wakeupTime.hour,
                wakeupMinute: profile.preferences.wakeupTime.minute,
                sleepHour: profile.preferences.sleepTime.hour,
                sleepMinute: profile.preferences.sleepTime.minute
            )
        )
        try modelContext.save()
    }
}
