import Combine

public protocol FetchStorefrontUseCase: Sendable {
    func execute() async throws -> Storefront
    func observe() -> AnyPublisher<Storefront, Error>
}

public extension FetchStorefrontUseCase {
    func observe() -> AnyPublisher<Storefront, Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchStorefrontUseCase: FetchStorefrontUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func observe() -> AnyPublisher<Storefront, Error> {
        repository.observeStoreItems()
            .combineLatest(repository.observeStoreInventory())
            .combineLatest(
                AsyncValuePublisher.make {
                    try await repository.fetchEquippedItems()
                }
                .prepend([])
                .catch { _ in Empty<[EquippedItem], Error>() }
            )
            .map { catalogAndInventory, equippedItems in
                Storefront(
                    catalog: catalogAndInventory.0,
                    inventory: catalogAndInventory.1,
                    equippedItems: equippedItems
                )
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func execute() async throws -> Storefront {
        async let catalog = repository.fetchStoreItems()
        async let inventory = repository.fetchStoreInventory()
        async let equippedItems = repository.fetchEquippedItems()
        return try await Storefront(
            catalog: catalog,
            inventory: inventory,
            equippedItems: equippedItems
        )
    }
}
