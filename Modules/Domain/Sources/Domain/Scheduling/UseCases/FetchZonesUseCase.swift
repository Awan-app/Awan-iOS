public protocol FetchZonesUseCase: Sendable {
    func execute() async throws -> [Zone]
}

public struct DefaultFetchZonesUseCase: FetchZonesUseCase {
    private let repository: any ZoneRepository

    public init(repository: any ZoneRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Zone] {
        try await repository.fetchZones()
    }
}
