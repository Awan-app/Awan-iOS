public protocol FetchStorefrontUseCase: Sendable {
    func execute() async throws -> Storefront
}

public struct DefaultFetchStorefrontUseCase: FetchStorefrontUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
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
