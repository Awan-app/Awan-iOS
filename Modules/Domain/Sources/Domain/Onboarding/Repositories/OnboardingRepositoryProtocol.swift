public protocol OnboardingRepositoryProtocol: Sendable {
    func completeOnboarding(_ request: CompleteOnboardingRequest) async throws -> UserProfile
}
