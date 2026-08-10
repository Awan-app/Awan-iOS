public protocol SpinDailyWheelUseCase: Sendable {
    func execute() async throws -> DailyWheelSpinResult
}

public struct DefaultSpinDailyWheelUseCase: SpinDailyWheelUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> DailyWheelSpinResult {
        try await repository.spinWheel()
    }
}
