import Combine
import Domain

public protocol LocalGamificationDataSource: Sendable {
    func observeStoreItems() -> AnyPublisher<[StoreItem], Error>
    func fetchStoreItems() async throws -> [StoreItem]
    func replaceStoreItems(_ items: [StoreItem]) async throws

    func observeInventoryItems() -> AnyPublisher<[InventoryItem], Error>
    func fetchInventoryItems() async throws -> [InventoryItem]
    func replaceInventoryItems(_ items: [InventoryItem]) async throws
    func upsertInventoryItem(_ item: InventoryItem) async throws
}
