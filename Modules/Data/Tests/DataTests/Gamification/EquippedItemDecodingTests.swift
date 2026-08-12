import Data
import Domain
import XCTest

final class EquippedItemDecodingTests: XCTestCase {
    func testEquippedItemResponseDTODecoding() throws {
        let json = """
        {
            "type": "FRAME",
            "item": {
                "id": "550e8400-e29b-41d4-a716-446655440010",
                "name": "Gold Frame",
                "description": "A shiny gold frame for your profile.",
                "image": "https://res.cloudinary.com/demo/image/upload/v1/ezdo/store/gold_frame.png",
                "info": null,
                "price": 100,
                "version": "1.0",
                "type": "FRAME"
            },
            "equippedAt": "2026-07-22T12:00:00Z"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(EquippedItemResponseDTO.self, from: json)
        XCTAssertEqual(dto.type, "FRAME")
        XCTAssertEqual(dto.item.id, "550e8400-e29b-41d4-a716-446655440010")
        XCTAssertEqual(dto.item.name, "Gold Frame")
        XCTAssertEqual(dto.equippedAt, "2026-07-22T12:00:00Z")
    }

    func testEquipStoreItemEndpoint() {
        let endpoint = GamificationEndpoint.equipStoreItem(itemID: "item-123")
        XCTAssertEqual(endpoint.path, "/store/items/item-123/equip")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNil(endpoint.queryParameters)
        XCTAssertNil(endpoint.body)
        XCTAssertTrue(endpoint.requiresAuthentication)
    }

    func testEquippedItemMapper() throws {
        let itemDTO = StoreItemResponseDTO(
            id: "item-frame-gold",
            name: "Gold Frame",
            description: "Gold frame desc",
            image: "https://example.com/frame.png",
            info: nil,
            price: 100,
            version: "1.0",
            type: "FRAME"
        )
        let dto = EquippedItemResponseDTO(
            type: "FRAME",
            item: itemDTO,
            equippedAt: "2026-07-22T12:00:00Z"
        )

        let domainModel = EquippedItemMapper.map(dto)
        XCTAssertEqual(domainModel.type, .frame)
        XCTAssertEqual(domainModel.item.id, "item-frame-gold")
        XCTAssertEqual(domainModel.item.name, "Gold Frame")
    }
}
