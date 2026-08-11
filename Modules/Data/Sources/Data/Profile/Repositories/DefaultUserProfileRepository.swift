import Combine
import AwaNetwork
import Domain
import Foundation

public struct DefaultUserProfileRepository: UserProfileRepository {
   
    
    private let localDataSource: any LocalUserProfileDataSource
    private let remoteDataSource: any RemoteProfileDataSource
    private let remoteGamificationDataSource: any RemoteGamificationDataSource
    
    public init(
        localDataSource: any LocalUserProfileDataSource,
        remoteDataSource: any RemoteProfileDataSource,
        remoteGamificationDataSource: any RemoteGamificationDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.remoteGamificationDataSource = remoteGamificationDataSource
    }

    public func fetchCurrentUser() async throws -> UserProfile {
        if let profile = try await localDataSource.fetchProfile() {
            return profile
        }
        return try await loadRemoteUser()
    }

    public func observeCurrentUser() -> AnyPublisher<UserProfile, Error> {
        let local = localDataSource.observeProfile()
            .compactMap { $0 }
            .eraseToAnyPublisher()
            
        let remote = AsyncValuePublisher.make { try await loadRemoteUser() }
            .catch { _ in Empty<UserProfile, Error>() }
            .eraseToAnyPublisher()
            
        return local
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func updateSessionDuration(_ durationMinutes: Int) async throws -> UserProfile {
        let request = UpdateProfilePartialRequestDTO(preferredSessionDuration: durationMinutes)
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
        return profile
    }

    public func updateTimezone(_ timezone: String) async throws -> UserProfile {
        let request = UpdateProfilePartialRequestDTO(timezone: timezone)
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
        return profile
    }
    public func updateSleepSchedule(wakeUpTime: String, sleepTime: String) async throws -> Domain.UserProfile {
        let currentProfile = try await fetchCurrentUser()
        let request = UpdateProfilePartialRequestDTO(
            firstName: currentProfile.firstName,
            lastName: currentProfile.lastName,
            birthDate: String(format: "%04d-%02d-%02d", currentProfile.birthDate.year, currentProfile.birthDate.month, currentProfile.birthDate.day),
            timezone: currentProfile.preferences.timezone,
            preferredSessionDuration: currentProfile.preferences.preferredSessionDuration,
            bufferBetweenSessions: currentProfile.preferences.bufferBetweenSessions,
            wakeupTime: wakeUpTime,
            sleepTime: sleepTime
        )
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
        return profile
    }

    public func updateSleepSchedule(_ sleepTime: String) async throws -> Domain.UserProfile {
        let request = UpdateProfilePartialRequestDTO(sleepTime: sleepTime)
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
        return profile
    }
    
    public func updateWakeUpSchedule(_ wakeUpTime: String) async throws -> Domain.UserProfile {
        let request = UpdateProfilePartialRequestDTO(wakeupTime: wakeUpTime)
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
        return profile
    }

    private func loadRemoteUser() async throws -> UserProfile {
        let profile = try HomeRemoteMapper.profile(try await remoteDataSource.getProfile())
        try await localDataSource.replaceProfile(profile)
        return profile
    }

    public func updateProfile(firstName: String?, lastName: String?, birthDate: String?) async throws {
        let request = UpdateProfilePartialRequestDTO(
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate
        )
        let response = try await remoteDataSource.updateProfilePartial(request)
        let profile = try HomeRemoteMapper.profile(response)
        try await localDataSource.replaceProfile(profile)
    }

    public func updateProfilePicture(data: Foundation.Data, fileName: String, mimeType: String) async throws {
        let file = MultipartFile(data: data, name: "image", fileName: fileName, mimeType: mimeType)
        _ = try await remoteDataSource.updateProfilePicture(file)
        
        // Refresh the profile to get the newly updated picture URL
        _ = try await loadRemoteUser()
    }
    
    public func refreshGamificationProgress() async throws {
        let progress = try await remoteGamificationDataSource.getProgress()

        try await localDataSource.updateGamification(
            points: progress.points,
            streak: progress.streak,
            maxStreak: progress.maxStreak
        )
    }
}
