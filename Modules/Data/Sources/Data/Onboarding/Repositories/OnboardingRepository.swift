import Domain

public final class OnboardingRepository: OnboardingRepositoryProtocol {
    private let remoteDataSource: any OnboardingDataSourceProtocol

    public init(remoteDataSource: any OnboardingDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }

    public func completeOnboarding(
        _ request: CompleteOnboardingRequest
    ) async throws -> UserProfile {
        do {
            let response = try await remoteDataSource.completeOnboarding(
                OnboardingMapper.toDTO(request)
            )
            let profile = try OnboardingMapper.toDomain(response)

            // Future auth-session synchronization: persist the current keychain session with `isNew` set to `false` after onboarding succeeds so relaunch routing remains correct.
            // try authSessionDataSource.markOnboardingCompleted()

            return profile
        } catch {
            throw OnboardingErrorMapper.map(error)
        }
    }
}
