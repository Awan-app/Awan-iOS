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

@MainActor
final class MarketplaceViewModelTests: XCTestCase {

    func testAppearedFetchesAllCategoryAggregated() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
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
            buyStoreItemUseCase: mockBuy
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
        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy
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
        mockFetch.shouldFail = true

        let viewModel = MarketplaceViewModel(
            fetchStoreItemsUseCase: mockFetch,
            buyStoreItemUseCase: mockBuy
        )
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(viewModel.state.errorMessage, "Failed to fetch store items")
        XCTAssertTrue(viewModel.state.allItems.isEmpty)
    }

    func testSuccessfulPurchaseUpdatesItemStatusToOwned() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()

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
            buyStoreItemUseCase: mockBuy
        )
        viewModel.state.allItems = [item]
        viewModel.state.selectedItem = item

        viewModel.send(.buyItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.purchasingItemID)
        XCTAssertEqual(mockBuy.lastBoughtItemID, "item-100")
        XCTAssertEqual(viewModel.state.allItems.first?.status, .owned)
        XCTAssertEqual(viewModel.state.selectedItem?.status, .owned)
        XCTAssertNotNil(viewModel.state.purchaseSuccessMessage)
        if case .success = viewModel.state.purchaseFeedback { } else {
            XCTFail("Expected purchaseFeedback to be .success")
        }
    }

    func testInsufficientPointsErrorMapsToLocalizedMessage() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()
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
            buyStoreItemUseCase: mockBuy
        )
        viewModel.state.allItems = [item]

        viewModel.send(.buyItem(item))

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNil(viewModel.state.purchasingItemID)
        XCTAssertNotNil(viewModel.state.purchaseErrorMessage)
        XCTAssertFalse(viewModel.state.purchaseErrorMessage?.contains("INSUFFICIENT_POINTS") ?? true)
        if case .failure = viewModel.state.purchaseFeedback { } else {
            XCTFail("Expected purchaseFeedback to be .failure")
        }
    }

    func testDuplicatePurchaseIgnoredWhenPurchasing() async throws {
        let mockFetch = MockFetchStoreItemsUseCaseImpl()
        let mockBuy = MockBuyStoreItemUseCaseImpl()

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
            buyStoreItemUseCase: mockBuy
        )
        viewModel.state.allItems = [item]
        viewModel.state.purchasingItemID = "other-in-progress"

        viewModel.send(.buyItem(item))

        XCTAssertNil(mockBuy.lastBoughtItemID)
        XCTAssertEqual(viewModel.state.purchasingItemID, "other-in-progress")
    }
}
