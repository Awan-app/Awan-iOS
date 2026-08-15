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

private final class MockFetchStoreItemsUseCaseImpl: FetchStoreItemsUseCase, @unchecked Sendable {
    var catalogToReturn: [StoreItem] = []
    var shouldFail: Bool = false

    func execute() async throws -> [StoreItem] {
        if shouldFail {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch store items"])
        }
        return catalogToReturn
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
            type: .frame,
            item: StoreItem(id: itemID, name: "Gold Frame", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame),
            equippedAt: Date()
        )
    }
}

private final class MockUnequipStoreItemUseCaseImpl: UnequipStoreItemUseCase, @unchecked Sendable {
    var lastUnequippedType: StoreItemType?
    var errorToThrow: (any Error)?
    var callCount: Int = 0

    func execute(type: StoreItemType) async throws {
        callCount += 1
        lastUnequippedType = type
        if let errorToThrow {
            throw errorToThrow
        }
    }
}

@MainActor
final class ProfileInventoryViewModelTests: XCTestCase {

    func testAppearedLoadsCatalogInventoryAndEquippedItemsConcurrently() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockCatalog = MockFetchStoreItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let ownedItem = StoreItem(id: "frame-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame)
        let lockedItem = StoreItem(id: "frame-2", name: "Frame 2", description: "Desc", image: "img", info: nil, price: 200, version: "1.0", type: .frame)

        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: ownedItem, boughtAt: Date())
        ]
        mockEquipped.equippedToReturn = [
            EquippedItem(type: .frame, item: ownedItem, equippedAt: Date())
        ]
        mockCatalog.catalogToReturn = [ownedItem, lockedItem]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            fetchStoreItemsUseCase: mockCatalog,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.inventoryItems.count, 1)
        XCTAssertEqual(viewModel.equippedItems.count, 1)
        XCTAssertEqual(viewModel.catalogItems.count, 2)
        XCTAssertEqual(viewModel.displayedOwnedItems.first?.status, .equipped)
        XCTAssertEqual(viewModel.displayedLockedItems.count, 1)
        XCTAssertEqual(viewModel.displayedLockedItems.first?.id, "frame-2")
        XCTAssertEqual(viewModel.displayedLockedItems.first?.status, .locked)
    }

    func testCategoryFilterFiltersAllSectionsCorrectly() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockCatalog = MockFetchStoreItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let frameItem = StoreItem(id: "f1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame)
        let skinItem = StoreItem(id: "s1", name: "Skin 1", description: "Desc", image: "img", info: nil, price: 200, version: "1.0", type: .skin)
        let lockedTheme = StoreItem(id: "t1", name: "Theme 1", description: "Desc", image: "img", info: nil, price: 300, version: "1.0", type: .theme)

        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: frameItem, boughtAt: Date()),
            InventoryItem(id: "inv-2", item: skinItem, boughtAt: Date())
        ]
        mockCatalog.catalogToReturn = [frameItem, skinItem, lockedTheme]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            fetchStoreItemsUseCase: mockCatalog,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.displayedOwnedItems.count, 2)
        XCTAssertEqual(viewModel.displayedLockedItems.count, 1)

        viewModel.send(.selectCategory(.frames))
        XCTAssertEqual(viewModel.displayedOwnedItems.count, 1)
        XCTAssertEqual(viewModel.displayedOwnedItems.first?.id, "f1")
        XCTAssertTrue(viewModel.displayedLockedItems.isEmpty)

        viewModel.send(.selectCategory(.themes))
        XCTAssertTrue(viewModel.displayedOwnedItems.isEmpty)
        XCTAssertEqual(viewModel.displayedLockedItems.count, 1)
        XCTAssertEqual(viewModel.displayedLockedItems.first?.id, "t1")
    }

    func testEquipOwnedItemUpdatesEquippedStateImmediately() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockCatalog = MockFetchStoreItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let item = StoreItem(id: "frame-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame)
        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: item, boughtAt: Date())
        ]
        mockCatalog.catalogToReturn = [item]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            fetchStoreItemsUseCase: mockCatalog,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        let targetMarketplaceItem = viewModel.displayedOwnedItems.first!
        viewModel.send(.equipItem(targetMarketplaceItem))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockEquip.lastEquippedItemID, "frame-1")
        XCTAssertEqual(viewModel.equippedItems.count, 1)
        XCTAssertEqual(viewModel.displayedOwnedItems.first?.status, .equipped)
    }

    func testUnequipItemRemovesFromEquippedAndChangesStatusToOwnedImmediately() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockCatalog = MockFetchStoreItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let item = StoreItem(id: "skin-1", name: "Skin 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .skin)
        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: item, boughtAt: Date())
        ]
        mockEquipped.equippedToReturn = [
            EquippedItem(type: .skin, item: item, equippedAt: Date())
        ]
        mockCatalog.catalogToReturn = [item]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            fetchStoreItemsUseCase: mockCatalog,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.displayedOwnedItems.first?.status, .equipped)

        let targetMarketplaceItem = viewModel.displayedOwnedItems.first!
        viewModel.send(.unequipItem(targetMarketplaceItem))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockUnequip.lastUnequippedType, .skin)
        XCTAssertTrue(viewModel.equippedItems.isEmpty)
        XCTAssertEqual(viewModel.displayedOwnedItems.first?.status, .owned)
    }

    func testUnequipItemSetsUnequippingItemTypePerItemAndClearsAfterwards() async throws {
        let mockInventory = MockFetchStoreInventoryUseCaseImpl()
        let mockEquipped = MockFetchEquippedItemsUseCaseImpl()
        let mockCatalog = MockFetchStoreItemsUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockUnequip = MockUnequipStoreItemUseCaseImpl()

        let frameItem = StoreItem(id: "frame-1", name: "Frame 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .frame)
        let skinItem = StoreItem(id: "skin-1", name: "Skin 1", description: "Desc", image: "img", info: nil, price: 100, version: "1.0", type: .skin)

        mockInventory.inventoryToReturn = [
            InventoryItem(id: "inv-1", item: frameItem, boughtAt: Date()),
            InventoryItem(id: "inv-2", item: skinItem, boughtAt: Date())
        ]
        mockEquipped.equippedToReturn = [
            EquippedItem(type: .frame, item: frameItem, equippedAt: Date()),
            EquippedItem(type: .skin, item: skinItem, equippedAt: Date())
        ]
        mockCatalog.catalogToReturn = [frameItem, skinItem]

        let viewModel = ProfileInventoryViewModel(
            fetchStoreInventoryUseCase: mockInventory,
            fetchEquippedItemsUseCase: mockEquipped,
            fetchStoreItemsUseCase: mockCatalog,
            equipStoreItemUseCase: mockEquip,
            unequipStoreItemUseCase: mockUnequip
        )

        viewModel.send(.appeared)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNil(viewModel.unequippingItemType)

        let targetMarketplaceItem = viewModel.displayedOwnedItems.first { $0.category == .frames }!
        viewModel.send(.unequipItem(targetMarketplaceItem))

        // Check unequippingItemType matches FRAME type specifically
        XCTAssertEqual(viewModel.unequippingItemType, .frame)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.unequippingItemType)
    }
}
