//
//  MarketplaceViewModelTests.swift
//  PresentationTests
//

import Domain
import Presentation
import XCTest

private final class MockFetchStoreItemsUseCaseImpl: FetchStoreItemsUseCase, @unchecked Sendable {
    var requestedTypes: [String] = []
    var shouldFail: Bool = false
    var itemsPerType: [String: [StoreItem]] = [:]

    func execute(type: String) async throws -> [StoreItem] {
        requestedTypes.append(type)
        if shouldFail {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch store items"])
        }
        return itemsPerType[type] ?? []
    }
}

private final class MockBuyStoreItemUseCaseImpl: BuyStoreItemUseCase, @unchecked Sendable {
    var lastBoughtItemID: String?
    var errorToThrow: (any Error)?
    var purchaseToReturn: StorePurchase?

    func execute(itemID: String) async throws -> StorePurchase {
        lastBoughtItemID = itemID
        if let errorToThrow {
            throw errorToThrow
        }
        return purchaseToReturn ?? StorePurchase(
            id: "purchase-1",
            item: StoreItem(
                id: itemID,
                name: "Gold Frame",
                description: "Shiny",
                image: "img",
                info: nil,
                price: 100,
                version: "1.0",
                type: "FRAME"
            ),
            boughtAt: Date()
        )
    }
}

private final class MockEquipStoreItemUseCaseImpl: EquipStoreItemUseCase, @unchecked Sendable {
    var lastEquippedItemID: String?
    var errorToThrow: (any Error)?
    var executeCallCount: Int = 0

    func execute(itemID: String) async throws -> EquippedItem {
        executeCallCount += 1
        lastEquippedItemID = itemID
        if let errorToThrow {
            throw errorToThrow
        }
        return EquippedItem(
            type: "FRAME",
            item: StoreItem(
                id: itemID,
                name: "Gold Frame",
                description: "Shiny",
                image: "img",
                info: nil,
                price: 100,
                version: "1.0",
                type: "FRAME"
            ),
            equippedAt: Date()
        )
    }
}

private final class MockFetchUserPointsUseCaseImpl: FetchUserPointsUseCase, @unchecked Sendable {
    var pointsToReturn: Int = 1500
    var shouldFail: Bool = false
    var executeCallCount: Int = 0

    func execute() async throws -> Int {
        executeCallCount += 1
        if shouldFail {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch points"])
        }
        return pointsToReturn
    }
}

@MainActor
final class MarketplaceViewModelTests: XCTestCase {

    func testAppearedFetchesAllCategoryAggregated() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockFetch.itemsPerType["FRAME"] = [
            StoreItem(id: "f1", name: "Frame 1", description: "Desc", image: "img1", info: nil, price: 100, version: "1.0", type: "FRAME")
        ]
        mockFetch.itemsPerType["SKIN"] = [
            StoreItem(id: "s1", name: "Skin 1", description: "Desc", image: "img2", info: nil, price: 200, version: "1.0", type: "SKIN")
        ]
        mockFetch.itemsPerType["THEME"] = [
            StoreItem(id: "t1", name: "Theme 1", description: "Desc", image: "img3", info: nil, price: 300, version: "1.0", type: "THEME")
        ]
        mockFetch.itemsPerType["ICON"] = [
            StoreItem(id: "i1", name: "Icon 1", description: "Desc", image: "img4", info: nil, price: 400, version: "1.0", type: "ICON")
        ]

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(viewModel.state.allItems.count, 4)

        XCTAssertTrue(mockFetch.requestedTypes.contains("FRAME"))
        XCTAssertTrue(mockFetch.requestedTypes.contains("SKIN"))
        XCTAssertTrue(mockFetch.requestedTypes.contains("THEME"))
        XCTAssertTrue(mockFetch.requestedTypes.contains("ICON"))
        XCTAssertFalse(mockFetch.requestedTypes.contains("ALL"))
        XCTAssertFalse(mockFetch.requestedTypes.contains("APP_ICON"))
    }

    func testSelectSpecificCategoriesSendsExactApiTypes() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )

        viewModel.send(.selectCategory(.skins))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockFetch.requestedTypes.last, "SKIN")

        viewModel.send(.selectCategory(.frames))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockFetch.requestedTypes.last, "FRAME")

        viewModel.send(.selectCategory(.themes))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockFetch.requestedTypes.last, "THEME")

        viewModel.send(.selectCategory(.appIcons))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockFetch.requestedTypes.last, "ICON")

        XCTAssertFalse(mockFetch.requestedTypes.contains("ALL"))
        XCTAssertFalse(mockFetch.requestedTypes.contains("APP_ICON"))
    }

    func testErrorHandlingInViewModel() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockFetch.shouldFail = true

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(viewModel.state.errorMessage, "Failed to fetch store items")
        XCTAssertTrue(viewModel.state.allItems.isEmpty)
    }

    func testAppearedFetchesUserPointsFromBackend() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockPoints.pointsToReturn = 2450

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.state.userPoints, 2450)
        XCTAssertEqual(mockPoints.executeCallCount, 1)
    }

    func testUserPointsUnchangedOnFetchUserPointsFailure() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockPoints.shouldFail = true

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.userPoints = 500
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.state.userPoints, 500)
    }

    func testSuccessfulPurchaseRefreshesPointsFromBackendUseCase() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockPoints.pointsToReturn = 1000

        let item = MarketplaceItem(
            id: "item-100",
            name: "Gold Frame",
            description: "Shiny",
            category: .frames,
            status: .price(100),
            symbolName: "star"
        )
        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]
        viewModel.state.selectedItem = item
        viewModel.state.userPoints = 1100

        mockPoints.pointsToReturn = 900

        viewModel.send(.buyItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.purchasingItemID)
        XCTAssertEqual(mockBuy.lastBoughtItemID, "item-100")
        XCTAssertEqual(viewModel.state.allItems.first?.status, .owned)
        XCTAssertEqual(viewModel.state.selectedItem?.status, .owned)
        XCTAssertEqual(viewModel.state.userPoints, 900)
        XCTAssertNotNil(viewModel.state.purchaseSuccessMessage)
        if case .success = viewModel.state.purchaseFeedback { } else {
            XCTFail("Expected purchaseFeedback to be .success")
        }
    }

    func testInsufficientPointsErrorLeavesPointsUnchanged() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockBuy.errorToThrow = GamificationError.insufficientPoints

        let item = MarketplaceItem(
            id: "item-200",
            name: "Expensive Theme",
            description: "Lots of pts",
            category: .themes,
            status: .price(5000),
            symbolName: "sun.max"
        )
        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]
        viewModel.state.userPoints = 300

        viewModel.send(.buyItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.purchasingItemID)
        XCTAssertEqual(viewModel.state.userPoints, 300)
        XCTAssertNotNil(viewModel.state.purchaseErrorMessage)
        XCTAssertFalse(viewModel.state.purchaseErrorMessage?.contains("INSUFFICIENT_POINTS") ?? true)
        if case .failure = viewModel.state.purchaseFeedback { } else {
            XCTFail("Expected purchaseFeedback to be .failure")
        }
    }

    func testDuplicatePurchaseIgnoredWhenPurchasing() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()

        let item = MarketplaceItem(
            id: "item-300",
            name: "Icon",
            description: "Desc",
            category: .appIcons,
            status: .price(50),
            symbolName: "app"
        )
        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]
        viewModel.state.purchasingItemID = "other-in-progress"

        viewModel.send(.buyItem(item))

        XCTAssertNil(mockBuy.lastBoughtItemID)
        XCTAssertEqual(viewModel.state.purchasingItemID, "other-in-progress")
    }

    // MARK: - Equipping Tests

    func testEquipOwnedItemChangesStatusToEquippedAndReplacesPreviousOfSameType() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()

        let prevEquippedFrame = MarketplaceItem(
            id: "frame-1",
            name: "Silver Frame",
            description: "Silver",
            category: .frames,
            status: .equipped,
            symbolName: "circle"
        )

        let ownedFrameToEquip = MarketplaceItem(
            id: "frame-2",
            name: "Gold Frame",
            description: "Gold",
            category: .frames,
            status: .owned,
            symbolName: "star"
        )

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [prevEquippedFrame, ownedFrameToEquip]
        viewModel.state.selectedItem = ownedFrameToEquip
        viewModel.state.userPoints = 1200

        viewModel.send(.equipItem(ownedFrameToEquip))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.equippingItemID)
        XCTAssertEqual(mockEquip.lastEquippedItemID, "frame-2")

        let frame1Status = viewModel.state.allItems.first(where: { $0.id == "frame-1" })?.status
        let frame2Status = viewModel.state.allItems.first(where: { $0.id == "frame-2" })?.status

        XCTAssertEqual(frame1Status, .owned, "Previous equipped item of same type must remain owned")
        XCTAssertEqual(frame2Status, .equipped, "Equipped item status must become .equipped")
        XCTAssertEqual(viewModel.state.selectedItem?.status, .equipped)
        XCTAssertEqual(viewModel.state.userPoints, 1200, "Equipping must NOT modify points")

        if case .success = viewModel.state.purchaseFeedback { } else {
            XCTFail("Expected purchaseFeedback to be .success after equip")
        }
    }

    func testEquipNonOwnedItemIsIgnored() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()

        let unownedItem = MarketplaceItem(
            id: "frame-3",
            name: "Diamond Frame",
            description: "Diamond",
            category: .frames,
            status: .price(1000),
            symbolName: "diamond"
        )

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [unownedItem]

        viewModel.send(.equipItem(unownedItem))

        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNil(mockEquip.lastEquippedItemID)
        XCTAssertEqual(mockEquip.executeCallCount, 0)
    }

    func testEquipItemNotOwnedErrorShowsLocalizedError() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()
        mockEquip.errorToThrow = GamificationError.itemNotOwned

        let item = MarketplaceItem(
            id: "skin-1",
            name: "Fire Skin",
            description: "Fiery",
            category: .skins,
            status: .owned,
            symbolName: "flame"
        )

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]

        viewModel.send(.equipItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.equippingItemID)
        XCTAssertNotNil(viewModel.state.purchaseErrorMessage)
        if case let .failure(msg) = viewModel.state.purchaseFeedback {
            XCTAssertFalse(msg.contains("ITEM_NOT_OWNED"))
        } else {
            XCTFail("Expected failure feedback on ITEM_NOT_OWNED")
        }
    }

    func testEquipLoadingStatePreventsDuplicateRequests() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()

        let item = MarketplaceItem(
            id: "theme-1",
            name: "Dark Theme",
            description: "Dark",
            category: .themes,
            status: .owned,
            symbolName: "moon"
        )

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]
        viewModel.state.equippingItemID = "other-in-progress"

        viewModel.send(.equipItem(item))

        XCTAssertNil(mockEquip.lastEquippedItemID)
        XCTAssertEqual(mockEquip.executeCallCount, 0)
    }

    func testReEquippingSameItemIsHandledSafely() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
        let mockEquip = MockEquipStoreItemUseCaseImpl()
        let mockPoints = MockFetchUserPointsUseCaseImpl()

        let item = MarketplaceItem(
            id: "icon-1",
            name: "Star Icon",
            description: "Star",
            category: .appIcons,
            status: .equipped,
            symbolName: "star"
        )

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy,
            equipStoreItemUseCase: mockEquip,
            fetchUserPointsUseCase: mockPoints
        )
        viewModel.state.allItems = [item]

        viewModel.send(.equipItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(viewModel.state.allItems.first?.status, .equipped)
        XCTAssertEqual(mockEquip.lastEquippedItemID, "icon-1")
    }
}
