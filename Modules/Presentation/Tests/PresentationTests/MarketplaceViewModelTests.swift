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

@MainActor
final class MarketplaceViewModelTests: XCTestCase {

    func testAppearedFetchesAllCategoryAggregated() async throws {
        let mockUseCase = MockFetchStoreItemsUseCaseImpl()
        mockUseCase.itemsPerType["FRAME"] = [
            StoreItem(id: "f1", name: "Frame 1", description: "Desc", image: "img1", info: nil, price: 100, version: "1.0", type: "FRAME")
        ]
        mockUseCase.itemsPerType["SKIN"] = [
            StoreItem(id: "s1", name: "Skin 1", description: "Desc", image: "img2", info: nil, price: 200, version: "1.0", type: "SKIN")
        ]
        mockUseCase.itemsPerType["THEME"] = [
            StoreItem(id: "t1", name: "Theme 1", description: "Desc", image: "img3", info: nil, price: 300, version: "1.0", type: "THEME")
        ]
        mockUseCase.itemsPerType["ICON"] = [
            StoreItem(id: "i1", name: "Icon 1", description: "Desc", image: "img4", info: nil, price: 400, version: "1.0", type: "ICON")
        ]

        let viewModel = MarketplaceViewModel(fetchStoreItemsUseCase: mockUseCase)
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNil(viewModel.state.errorMessage)
        XCTAssertEqual(viewModel.state.allItems.count, 4)

        XCTAssertTrue(mockUseCase.requestedTypes.contains("FRAME"))
        XCTAssertTrue(mockUseCase.requestedTypes.contains("SKIN"))
        XCTAssertTrue(mockUseCase.requestedTypes.contains("THEME"))
        XCTAssertTrue(mockUseCase.requestedTypes.contains("ICON"))
        XCTAssertFalse(mockUseCase.requestedTypes.contains("ALL"))
        XCTAssertFalse(mockUseCase.requestedTypes.contains("APP_ICON"))
    }

    func testSelectSpecificCategoriesSendsExactApiTypes() async throws {
        let mockUseCase = MockFetchStoreItemsUseCaseImpl()
        let viewModel = MarketplaceViewModel(fetchStoreItemsUseCase: mockUseCase)

        viewModel.send(.selectCategory(.skins))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockUseCase.requestedTypes.last, "SKIN")

        viewModel.send(.selectCategory(.frames))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockUseCase.requestedTypes.last, "FRAME")

        viewModel.send(.selectCategory(.themes))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockUseCase.requestedTypes.last, "THEME")

        viewModel.send(.selectCategory(.appIcons))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(mockUseCase.requestedTypes.last, "ICON")

        XCTAssertFalse(mockUseCase.requestedTypes.contains("ALL"))
        XCTAssertFalse(mockUseCase.requestedTypes.contains("APP_ICON"))
    }

    func testErrorHandlingInViewModel() async throws {
        let mockUseCase = MockFetchStoreItemsUseCaseImpl()
        mockUseCase.shouldFail = true

        let viewModel = MarketplaceViewModel(fetchStoreItemsUseCase: mockUseCase)
        viewModel.send(.appeared)

        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertEqual(viewModel.state.errorMessage, "Failed to fetch store items")
        XCTAssertTrue(viewModel.state.allItems.isEmpty)
    }
}
