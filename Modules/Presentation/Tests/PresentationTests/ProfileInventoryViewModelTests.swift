//
//  ProfileInventoryViewModelTests.swift
//  PresentationTests
//

import Domain
import Presentation
import XCTest

private final class MockFetchStoreInventoryUseCaseImpl: FetchStoreInventoryUseCase, @unchecked Sendable {
    var inventoryToReturn: [InventoryItem] = []
    var shouldFail: Bool = false

    func execute() async throws -> [InventoryItem] {
        if shouldFail {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch inventory"])
        }
        return inventoryToReturn
    }
}

private final class MockFetchEquippedItemsUseCaseImpl: FetchEquippedItemsUseCase, @unchecked Sendable {
    var equippedToReturn: [EquippedItem] = []
    var shouldFail: Bool = false

    func execute() async throws -> [EquippedItem] {
        if shouldFail {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch equipped items"])
        }
        return equippedToReturn
    }
}

private final class MockEquipStoreItemUseCaseImpl: EquipStoreItemUseCase, @unchecked Sendable {
    var lastEquippedItemID: String?
    var errorToThrow: (any Error)?
    var callCount: Int = 0

    func execute(itemID: String) async throws -> EquippedItem {
        callCount += 1
        lastEquippedItemID = itemID
        if let errorToThrow {
            throw errorToThrow
        }
        return EquippedItem(
            type: "FRAME",
            item: StoreItem(id: itemID, name: "Gold Frame", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: "FRAME"),
            equippedAt: Date()
        )
    }
}

private final class MockUnequipStoreItemUseCaseImpl: UnequipStoreItemUseCase, @unchecked Sendable {
    var lastUnequippedType: String?
    var errorToThrow: (any Error)?
    var callCount: Int = 0

    func execute(type: String) async throws {
        callCount += 1
        lastUnequippedType = type
        if let errorToThrow {
            throw errorToThrow
        }
    }
}

@MainActor
final class ProfileInventoryViewModelTests: XCTestCase {

    func testAppearedLoadsInventoryAndEquippedItemsConcurrently() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let item1 = StoreItem(id: "frame-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: "FRAME")
        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: item1, boughtAt: Date())
        ]
        mockEquipped.equippedToReturn = [
            EquippedItem(type: "FRAME", item: item1, equippedAt: Date())
        ]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.inventoryItems.count, 1)
        XCTAssertEqual(viewModel.equippedItems.count, 1)
        XCTAssertEqual(viewModel.displayedItems.first?.status, .equipped)
    }

    func testCategoryFilterFiltersItemsCorrectly() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let frameItem = StoreItem(id: "f1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: "FRAME")
        let skinItem = StoreItem(id: "s1", name: "Skin 1", description: "Desc", image: "img", info: nil, price: 200, version: "1.0", type: "SKIN")

        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: frameItem, boughtAt: Date()),
            InventoryItem(id: "inv-2", item: skinItem, boughtAt: Date())
        ]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.displayedItems.count, 2)

        viewModel.send(.selectCategory(.frames))
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertEqual(viewModel.displayedItems.first?.id, "f1")

        viewModel.send(.selectCategory(.skins))
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertEqual(viewModel.displayedItems.first?.id, "s1")
    }

    func testEquipOwnedItemUpdatesEquippedState() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let item = StoreItem(id: "frame-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: "FRAME")
        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: item, boughtAt: Date())
        ]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        let targetMarketplaceItem = viewModel.displayedItems.first!
        viewModel.send(.equipItem(targetMarketplaceItem))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockEquip.lastEquippedItemID, "frame-1")
        XCTAssertEqual(viewModel.equippedItems.count, 1)
        XCTAssertEqual(viewModel.displayedItems.first?.status, .equipped)
    }

    func testUnequipItemRemovesFromEquippedAndChangesStatusToOwned() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let item = StoreItem(id: "skin-1", name: "Skin 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: "SKIN")
        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: item, boughtAt: Date())
        ]
        mockEquipped.equippedToReturn = [
            EquippedItem(type: "SKIN", item: item, equippedAt: Date())
        ]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.displayedItems.first?.status, .equipped)

        let targetMarketplaceItem = viewModel.displayedItems.first!
        viewModel.send(.unequipItem(targetMarketplaceItem))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUnequip.lastUnequippedType, "SKIN")
        XCTAssertTrue(viewModel.equippedItems.isEmpty)
        XCTAssertEqual(viewModel.displayedItems.first?.status, .owned)
    }
}
