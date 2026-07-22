import Foundation
import SwiftData

@Model
final class UserProfileModel {
    @Attribute(.unique) var id: UUID
    var email: String
    var firstName: String
    var lastName: String
    var birthYear: Int
    var birthMonth: Int
    var birthDay: Int
    var points: Int
    var streak: Int
    var maxStreak: Int
    var timezone: String
    var preferredSessionDuration: Int
    var bufferBetweenSessions: Int
    var wakeupHour: Int
    var wakeupMinute: Int
    var sleepHour: Int
    var sleepMinute: Int

    init(
        id: UUID,
        email: String,
        firstName: String,
        lastName: String,
        birthYear: Int,
        birthMonth: Int,
        birthDay: Int,
        points: Int,
        streak: Int,
        maxStreak: Int,
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupHour: Int,
        wakeupMinute: Int,
        sleepHour: Int,
        sleepMinute: Int
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthYear = birthYear
        self.birthMonth = birthMonth
        self.birthDay = birthDay
        self.points = points
        self.streak = streak
        self.maxStreak = maxStreak
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupHour = wakeupHour
        self.wakeupMinute = wakeupMinute
        self.sleepHour = sleepHour
        self.sleepMinute = sleepMinute
    }
}
