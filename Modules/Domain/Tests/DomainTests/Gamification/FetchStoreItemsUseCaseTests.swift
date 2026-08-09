//
//  FetchStoreItemsUseCaseTests.swift
//  DomainTests
//

import XCTest
import Domain

private final class StoreItemRepositoryStub: StoreItemRepository, @unchecked Sendable {
    var requestedTypes: [String] = []
    var mockItemsToReturn: [String: [StoreItem]] = [:]

    func fetchStoreItems(type: String) async throws -> [StoreItem] {
        requestedTypes.append(type)
        return mockItemsToReturn[type] ?? []
    }
}

final class FetchStoreItemsUseCaseTests: XCTestCase {

    func testExecuteForwardsTypeToRepository() async throws {
        let stub = StoreItemRepositoryStub()
        let expectedItem = StoreItem(
            id: "1",
            name: "Gold Frame",
            description: "Desc",
            image: "img.png",
            info: nil,
            price: 100,
            version: "1.0",
            type: "FRAME"
        )
        stub.mockItemsToReturn["FRAME"] = [expectedItem]

        let useCase = DefaultFetchStoreItemsUseCase(repository: stub)
        let items = try await useCase.execute(type: "FRAME")

        XCTAssertEqual(stub.requestedTypes, ["FRAME"])
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Gold Frame")
    }
}
