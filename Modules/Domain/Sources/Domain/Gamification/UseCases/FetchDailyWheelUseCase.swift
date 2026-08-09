public protocol FetchDailyWheelUseCase: Sendable {
    func execute() async throws -> DailyWheelConfiguration
}

public struct DefaultFetchDailyWheelUseCase: FetchDailyWheelUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> DailyWheelConfiguration {
        try await repository.fetchWheelConfig()
    }
}
