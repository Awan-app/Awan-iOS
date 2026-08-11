import Domain
import XCTest

final class EquipStoreItemUseCaseTests: XCTestCase {
    private final class MockGamificationRepository: GamificationRepository, @unchecked Sendable {
        var lastEquippedItemID: String?
        var errorToThrow: (any Error)?

        func fetchStoreItems(type: String) async throws -> [StoreItem] { [] }
        func buyStoreItem(itemID: String) async throws -> StorePurchase {
            fatalError("Unimplemented")
        }

        func equipStoreItem(itemID: String) async throws -> EquippedItem {
            lastEquippedItemID = itemID
            if let errorToThrow {
                throw errorToThrow
            }
            return EquippedItem(
                type: "FRAME",
                item: StoreItem(
                    id: itemID,
                    name: "Gold Frame",
                    description: "Shiny gold frame",
                    image: "https://example.com/gold.png",
                    info: nil,
                    price: 100,
                    version: "1.0",
                    type: "FRAME"
                ),
                equippedAt: Date()
            )
        }

        func unequipStoreItem(type: String) async throws {}
        func fetchEquippedItems() async throws -> [EquippedItem] { [] }
        func fetchStoreInventory() async throws -> [InventoryItem] { [] }
        func fetchUserPoints() async throws -> Int { 0 }
        func fetchWheelConfig() async throws -> DailyWheelConfiguration {
            fatalError("Unimplemented")
        }
        func spinWheel() async throws -> DailyWheelSpinResult {
            fatalError("Unimplemented")
        }
    }

    func testExecuteCallsRepositoryEquipStoreItem() async throws {
        let repo = MockGamificationRepository()
        let useCase = DefaultEquipStoreItemUseCase(repository: repo)

        let equippedItem = try await useCase.execute(itemID: "item-frame-1")

        XCTAssertEqual(repo.lastEquippedItemID, "item-frame-1")
        XCTAssertEqual(equippedItem.item.id, "item-frame-1")
        XCTAssertEqual(equippedItem.type, "FRAME")
    }

    func testExecutePropagatesRepositoryError() async {
        let repo = MockGamificationRepository()
        repo.errorToThrow = GamificationError.itemNotOwned
        let useCase = DefaultEquipStoreItemUseCase(repository: repo)

        do {
            _ = try await useCase.execute(itemID: "item-not-owned")
            XCTFail("Expected error to be thrown")
        } catch let error as GamificationError {
            XCTAssertEqual(error, GamificationError.itemNotOwned)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
