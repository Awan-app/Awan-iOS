import Domain
import Foundation

enum OnboardingMapper {
    static func toDTO(_ request: CompleteOnboardingRequest) -> OnboardingRequestDTO {
        OnboardingRequestDTO(
            firstName: request.firstName,
            lastName: request.lastName,
            birthDate: format(request.birthDate),
            timezone: request.timezone,
            preferredSessionDuration: request.preferredSessionDuration,
            bufferBetweenSessions: request.bufferBetweenSessions,
            wakeupTime: format(request.wakeupTime),
            sleepTime: format(request.sleepTime)
        )
    }

    static func toDomain(_ response: OnboardingResponseDTO) throws -> UserProfile {
        UserProfile(
            id: response.id,
            email: response.email,
            firstName: response.firstName,
            lastName: response.lastName,
            birthDate: try parseBirthDate(response.birthDate),
            points: response.points,
            streak: response.streak,
            maxStreak: response.maxStreak,
            preferences: UserPreferences(
                timezone: response.preferences.timezone,
                preferredSessionDuration: response.preferences.preferredSessionDuration,
                bufferBetweenSessions: response.preferences.bufferBetweenSessions,
                wakeupTime: try parseTime(response.preferences.wakeupTime),
                sleepTime: try parseTime(response.preferences.sleepTime)
            )
        )
    }

    private static func format(_ date: BirthDate) -> String {
        String(format: "%04d-%02d-%02d", date.year, date.month, date.day)
    }

    private static func format(_ time: LocalTime) -> String {
        String(format: "%02d:%02d:00", time.hour, time.minute)
    }

    private static func parseBirthDate(_ value: String) throws -> BirthDate {
        let parts = value.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            throw OnboardingError.invalidResponse
        }

        do {
            return try BirthDate(year: year, month: month, day: day)
        } catch {
            throw OnboardingError.invalidResponse
        }
    }

    private static func parseTime(_ value: String) throws -> LocalTime {
        let parts = value.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            throw OnboardingError.invalidResponse
        }

        do {
            return try LocalTime(hour: hour, minute: minute)
        } catch {
            throw OnboardingError.invalidResponse
        }
    }
}
