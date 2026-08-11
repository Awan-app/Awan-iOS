public protocol GamificationRepository: Sendable {
    func fetchWheelConfig() async throws -> DailyWheelConfiguration
    func spinWheel() async throws -> DailyWheelSpinResult

    func fetchActivityDays(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay>
}
