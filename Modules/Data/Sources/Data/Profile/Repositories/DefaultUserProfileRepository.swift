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

    private func loadRemoteUser() async throws -> UserProfile {
        let profile = try HomeRemoteMapper.profile(try await remoteDataSource.getProfile())
        try await localDataSource.replaceProfile(profile)
        return profile
    }
}
