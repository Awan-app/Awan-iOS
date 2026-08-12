//
//  ProfileInventoryUseCasesTests.swift
//  DomainTests
//

import Domain
import XCTest

final class ProfileInventoryUseCasesTests: XCTestCase {
    private final class MockGamificationRepository: GamificationRepository, @unchecked Sendable {
        var inventoryToReturn: [InventoryItem] = []
        var equippedToReturn: [EquippedItem] = []
        var lastUnequippedType: String?
        var errorToThrow: (any Error)?

        func fetchStoreItems() async throws -> [StoreItem] { [] }
        func buyStoreItem(itemID: String) async throws -> StorePurchase { fatalError("Unimplemented") }
        func equipStoreItem(itemID: String) async throws -> EquippedItem { fatalError("Unimplemented") }

        func unequipStoreItem(type: StoreItemType) async throws {
            lastUnequippedType = type
            if let errorToThrow {
                throw errorToThrow
            }
        }

        func fetchEquippedItems() async throws -> [EquippedItem] {
            if let errorToThrow {
                throw errorToThrow
            }
            return equippedToReturn
        }

        func fetchStoreInventory() async throws -> [InventoryItem] {
            if let errorToThrow {
                throw errorToThrow
            }
            return inventoryToReturn
        }

        func fetchUserPoints() async throws -> Int { 0 }
        func fetchWheelConfig() async throws -> DailyWheelConfiguration { fatalError("Unimplemented") }
        func spinWheel() async throws -> DailyWheelSpinResult { fatalError("Unimplemented") }
    }

    func testFetchStoreInventoryUseCaseCallsRepository() async throws {
        let repo = MockGamificationRepository()
        let sampleItem = InventoryItem(
            id: "inv-1",
            item: StoreItem(id: "item-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame),
            boughtAt: Date()
        )
        repo.inventoryToReturn = [sampleItem]

        let useCase = DefaultFetchStoreInventoryUseCase(repository: repo)
        let result = try await useCase.execute()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "inv-1")
    }

    func testUnequipStoreItemUseCaseCallsRepository() async throws {
        let repo = MockGamificationRepository()
        let useCase = DefaultUnequipStoreItemUseCase(repository: repo)

        try await useCase.execute(type: .frame)

        XCTAssertEqual(repo.lastUnequippedType, "FRAME")
    }
}
