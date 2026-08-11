import XCTest
@testable import Data
import Domain

final class StorePurchaseDecodingTests: XCTestCase {
    func testStorePurchaseResponseDTODecoding() throws {
        let json = """
        {
            "id": "purchase-550e8400",
            "item": {
                "id": "item-550e8400",
                "name": "Gold Frame",
                "description": "A shiny gold frame for your profile.",
                "image": "https://res.cloudinary.com/demo/image/upload/v1/ezdo/store/gold_frame.png",
                "info": null,
                "price": 100,
                "version": "1.0",
                "type": "FRAME"
            },
            "boughtAt": "2026-07-22T10:00:00Z"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(StorePurchaseResponseDTO.self, from: json)
        XCTAssertEqual(dto.id, "purchase-550e8400")
        XCTAssertEqual(dto.item.id, "item-550e8400")
        XCTAssertEqual(dto.item.name, "Gold Frame")
        XCTAssertEqual(dto.item.price, 100)
        XCTAssertEqual(dto.item.type, "FRAME")
        XCTAssertEqual(dto.boughtAt, "2026-07-22T10:00:00Z")
    }

    func testBuyStoreItemEndpoint() {
        let endpoint = GamificationEndpoint.buyStoreItem(itemID: "item-abc-123")
        XCTAssertEqual(endpoint.path, "/store/items/item-abc-123/buy")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNil(endpoint.queryParameters)
    }

    func testStorePurchaseMapper() throws {
        let itemDTO = StoreItemResponseDTO(
            id: "item-1",
            name: "Cloud Skin",
            description: "A soft cloud skin.",
            image: "https://example.com/cloud.png",
            info: nil,
            price: 250,
            version: "1.0",
            type: "SKIN"
        )
        let dto = StorePurchaseResponseDTO(
            id: "purchase-1",
            item: itemDTO,
            boughtAt: "2026-08-09T14:00:00Z"
        )

        let domainPurchase = StorePurchaseMapper.map(dto)
        XCTAssertEqual(domainPurchase.id, "purchase-1")
        XCTAssertEqual(domainPurchase.item.id, "item-1")
        XCTAssertEqual(domainPurchase.item.name, "Cloud Skin")
        XCTAssertEqual(domainPurchase.item.price, 250)
        XCTAssertEqual(domainPurchase.item.type, "SKIN")
    }
}
