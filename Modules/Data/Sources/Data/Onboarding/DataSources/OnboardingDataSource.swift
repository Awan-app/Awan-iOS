import AwaNetwork

public protocol OnboardingDataSourceProtocol: Sendable {
    func completeOnboarding(
        _ request: OnboardingRequestDTO
    ) async throws -> OnboardingResponseDTO
}

public final class OnboardingDataSource: OnboardingDataSourceProtocol {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func completeOnboarding(
        _ request: OnboardingRequestDTO
    ) async throws -> OnboardingResponseDTO {
        try await networkService.request(OnboardingEndpoint.complete(request))
    }
}
