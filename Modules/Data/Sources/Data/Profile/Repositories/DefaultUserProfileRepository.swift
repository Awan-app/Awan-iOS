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
}
