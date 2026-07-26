import Combine
import Domain

public struct DefaultUserProfileRepository: UserProfileRepository {
   
    
    private let localDataSource: any LocalUserProfileDataSource
    private let remoteDataSource: any RemoteProfileDataSource

    public init(
        localDataSource: any LocalUserProfileDataSource,
        remoteDataSource: any RemoteProfileDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetchCurrentUser() async throws -> UserProfile {
        guard let profile = try await localDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        return profile
    }

    public func observeCurrentUser() -> AnyPublisher<UserProfile, Error> {
        let cached = AsyncValuePublisher.make {
            try await localDataSource.fetchProfile()
        }
        .compactMap { $0 }
        let remote = AsyncValuePublisher.make { try await loadRemoteUser() }
        return cached.append(remote).eraseToAnyPublisher()
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
}
