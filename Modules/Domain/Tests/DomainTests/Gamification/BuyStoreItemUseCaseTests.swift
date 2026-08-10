import XCTest
@testable import Domain

final class BuyStoreItemUseCaseTests: XCTestCase {
    private final class MockRepository: GamificationRepository, @unchecked Sendable {
        var lastBoughtItemID: String?

        func fetchStoreItems(type: String) async throws -> [StoreItem] {
            []
        }

        func buyStoreItem(itemID: String) async throws -> StorePurchase {
            lastBoughtItemID = itemID
            return StorePurchase(
                id: "purchase-99",
                item: StoreItem(
                    id: itemID,
                    name: "Purchased Item",
                    description: "Desc",
                    image: "img",
                    info: nil,
                    price: 150,
                    version: "1.0",
                    type: "THEME"
                ),
                boughtAt: Date()
            )
        }

        func equipStoreItem(itemID: String) async throws -> EquippedItem {
            fatalError("Unimplemented")
        }

        func unequipStoreItem(type: String) async throws {}

        func fetchEquippedItems() async throws -> [EquippedItem] {
            []
        }

        func fetchStoreInventory() async throws -> [InventoryItem] {
            []
        }

        func fetchUserPoints() async throws -> Int {
            fatalError("Unimplemented")
        }

        func fetchWheelConfig() async throws -> DailyWheelConfiguration {
            fatalError("Unimplemented")
        }

        func spinWheel() async throws -> DailyWheelSpinResult {
            fatalError("Unimplemented")
        }
    }

    func testExecuteForwardsItemIDToRepository() async throws {
        let repo = MockRepository()
        let useCase = DefaultBuyStoreItemUseCase(repository: repo)

        let purchase = try await useCase.execute(itemID: "target-item-uuid")

        XCTAssertEqual(repo.lastBoughtItemID, "target-item-uuid")
        XCTAssertEqual(purchase.id, "purchase-99")
        XCTAssertEqual(purchase.item.id, "target-item-uuid")
    }
}
