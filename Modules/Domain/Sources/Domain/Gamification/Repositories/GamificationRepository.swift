public protocol GamificationRepository: Sendable {
    func fetchWheelConfig() async throws -> DailyWheelConfiguration
    func spinWheel() async throws -> DailyWheelSpinResult
}
