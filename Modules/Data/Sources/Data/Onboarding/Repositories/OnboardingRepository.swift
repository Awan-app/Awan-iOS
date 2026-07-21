import Domain

public final class OnboardingRepository: OnboardingRepositoryProtocol {
    private let remoteDataSource: any OnboardingDataSourceProtocol
    private let authSessionDataSource: any AuthSessionDataSource

    public init(
        remoteDataSource: any OnboardingDataSourceProtocol,
        authSessionDataSource: any AuthSessionDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.authSessionDataSource = authSessionDataSource
    }

    public func completeOnboarding(
        _ request: CompleteOnboardingRequest
    ) async throws -> UserProfile {
        do {
            let response = try await remoteDataSource.completeOnboarding(
                OnboardingMapper.toDTO(request)
            )
            let profile = try OnboardingMapper.toDomain(response)
            try authSessionDataSource.markOnboardingCompleted()

            return profile
        } catch {
            throw OnboardingErrorMapper.map(error)
        }
    }
}
