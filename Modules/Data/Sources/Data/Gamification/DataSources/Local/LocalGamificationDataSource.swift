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

    func observeEquippedItems() -> AnyPublisher<[EquippedItem], Error>
    func fetchEquippedItems() async throws -> [EquippedItem]
    func replaceEquippedItems(_ items: [EquippedItem]) async throws
    func upsertEquippedItem(_ item: EquippedItem) async throws
    func deleteEquippedItem(type: StoreItemType) async throws
}
