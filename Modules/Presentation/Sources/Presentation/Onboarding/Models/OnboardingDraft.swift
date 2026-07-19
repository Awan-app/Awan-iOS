import Domain
import Foundation

public struct OnboardingDraft: Equatable, Sendable {
    public var firstName: String
    public var lastName: String
    public var birthDate: Date
    public var timezone: String
    public var preferredSessionDuration: Int
    public var bufferBetweenSessions: Int
    public var wakeupTime: Date
    public var sleepTime: Date

    public init(
        firstName: String,
        lastName: String,
        birthDate: Date,
        timezone: String,
        preferredSessionDuration: Int,
        bufferBetweenSessions: Int,
        wakeupTime: Date,
        sleepTime: Date
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }

    public func makeRequest(
        calendar: Calendar = .current
    ) throws -> CompleteOnboardingRequest {
        let birthComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: birthDate
        )
        guard let year = birthComponents.year,
              let month = birthComponents.month,
              let day = birthComponents.day else {
            throw OnboardingInputError.invalidBirthDate
        }

        let wakeupComponents = calendar.dateComponents(
            [.hour, .minute],
            from: wakeupTime
        )
        guard let wakeupHour = wakeupComponents.hour,
              let wakeupMinute = wakeupComponents.minute else {
            throw OnboardingInputError.invalidWakeupTime
        }

        let sleepComponents = calendar.dateComponents(
            [.hour, .minute],
            from: sleepTime
        )
        guard let sleepHour = sleepComponents.hour,
              let sleepMinute = sleepComponents.minute else {
            throw OnboardingInputError.invalidSleepTime
        }

        return try CompleteOnboardingRequest(
            firstName: firstName,
            lastName: lastName,
            birthDate: BirthDate(year: year, month: month, day: day),
            timezone: timezone,
            preferredSessionDuration: preferredSessionDuration,
            bufferBetweenSessions: bufferBetweenSessions,
            wakeupTime: LocalTime(hour: wakeupHour, minute: wakeupMinute),
            sleepTime: LocalTime(hour: sleepHour, minute: sleepMinute)
        )
    }
}
