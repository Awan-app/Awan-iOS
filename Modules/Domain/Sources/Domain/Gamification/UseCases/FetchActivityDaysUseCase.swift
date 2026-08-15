public protocol FetchActivityDaysUseCase: Sendable {
    func execute(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay>
}

public struct DefaultFetchActivityDaysUseCase: FetchActivityDaysUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay> {
        guard startDay <= endDay else {
            throw GamificationError.invalidActivityRange
        }

        return try await repository.fetchActivityDays(
            from: startDay,
            through: endDay
        )
    }
}
