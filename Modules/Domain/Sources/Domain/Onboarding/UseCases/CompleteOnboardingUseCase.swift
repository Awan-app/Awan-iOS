public protocol CompleteOnboardingUseCase: Sendable {
    func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile
}

public struct CompleteOnboardingUseCaseImpl: CompleteOnboardingUseCase {
    private let repository: any OnboardingRepositoryProtocol

    public init(repository: any OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        try await repository.completeOnboarding(request)
    }
}
