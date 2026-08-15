//
//  FetchStoreItemsUseCaseTests.swift
//  DomainTests
//

import XCTest
import Domain

private final class StoreItemRepositoryStub: GamificationRepository, @unchecked Sendable {
    var fetchCallCount = 0
    var mockItemsToReturn: [StoreItem] = []

    func fetchStoreItems() async throws -> [StoreItem] {
        fetchCallCount += 1
        return mockItemsToReturn
    }

    func buyStoreItem(itemID: String) async throws -> StorePurchase {
        fatalError("Unimplemented")
    }

    func equipStoreItem(itemID: String) async throws -> EquippedItem {
        fatalError("Unimplemented")
    }

    func unequipStoreItem(type: StoreItemType) async throws {}

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

final class FetchStoreItemsUseCaseTests: XCTestCase {

    func testExecuteFetchesAllItemsFromRepository() async throws {
        let stub = StoreItemRepositoryStub()
        let expectedItem = StoreItem(
            id: "1",
            name: "Gold Frame",
            description: "Desc",
            image: "img.png",
            info: nil,
            price: 100,
            version: "1.0",
            type: .frame
        )
        stub.mockItemsToReturn = [expectedItem]

        let useCase = DefaultFetchStoreItemsUseCase(repository: stub)
        let items = try await useCase.execute()

        XCTAssertEqual(stub.fetchCallCount, 1)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Gold Frame")
    }
}
