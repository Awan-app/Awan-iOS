import Foundation
import Combine

public protocol UserProfileRepository: Sendable {
    func fetchCurrentUser() async throws -> UserProfile
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error>
    func updateProfile(firstName: String?, lastName: String?, birthDate: String?) async throws
    func updateProfilePicture(data: Data, fileName: String, mimeType: String) async throws
    func updateSessionDuration(_ durationMinutes: Int) async throws -> UserProfile
    func updateTimezone(_ timezone: String) async throws -> UserProfile
    func updateSleepSchedule(_ sleepTime: String) async throws -> UserProfile
    func updateWakeUpSchedule(_ wakeUpTime: String) async throws -> UserProfile
    func updateSleepSchedule(wakeUpTime: String, sleepTime: String) async throws -> UserProfile
    func refreshGamificationProgress() async throws
}

public extension UserProfileRepository {
    func observeCurrentUser() -> AnyPublisher<UserProfile, Error> {
        AsyncValuePublisher.make { try await fetchCurrentUser() }
    }
}
