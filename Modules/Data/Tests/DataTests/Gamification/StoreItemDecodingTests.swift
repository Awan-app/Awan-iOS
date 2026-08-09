//
//  StoreItemDecodingTests.swift
//  DataTests
//

import XCTest
@testable import Data
import Domain

final class StoreItemDecodingTests: XCTestCase {

    func testDecodeSingleStoreItemObject() throws {
        let json = """
        {
            "id": "1775d47e-3962-4368-83f2-b0429f368ee3",
            "name": "Gold Frame",
            "description": "A shiny gold frame for your profile.",
            "image": "https://res.cloudinary.com/demo/image/upload/v1/ezdo/store/gold_frame.png",
            "info": null,
            "price": 100,
            "version": "1.0",
            "type": "FRAME"
        }
        """.data(using: .utf8)!

        let decodedResponse = try JSONDecoder().decode(StoreItemsResponseDTO.self, from: json)
        XCTAssertEqual(decodedResponse.items.count, 1)

        let item = decodedResponse.items[0]
        XCTAssertEqual(item.id, "1775d47e-3962-4368-83f2-b0429f368ee3")
        XCTAssertEqual(item.name, "Gold Frame")
        XCTAssertEqual(item.description, "A shiny gold frame for your profile.")
        XCTAssertEqual(item.image, "https://res.cloudinary.com/demo/image/upload/v1/ezdo/store/gold_frame.png")
        XCTAssertNil(item.info)
        XCTAssertEqual(item.price, 100)
        XCTAssertEqual(item.version, "1.0")
        XCTAssertEqual(item.type, "FRAME")
    }

    func testDecodeArrayStoreItems() throws {
        let json = """
        [
            {
                "id": "item-1",
                "name": "Cloud Skin",
                "description": "Dreamy cloud skin",
                "image": "https://example.com/skin.png",
                "info": "Special edition",
                "price": 200,
                "version": "1.0",
                "type": "SKIN"
            },
            {
                "id": "item-2",
                "name": "Star Icon",
                "description": "Shining star icon",
                "image": "https://example.com/icon.png",
                "info": null,
                "price": 150,
                "version": "2.0",
                "type": "ICON"
            }
        ]
        """.data(using: .utf8)!

        let decodedResponse = try JSONDecoder().decode(StoreItemsResponseDTO.self, from: json)
        XCTAssertEqual(decodedResponse.items.count, 2)

        let item1 = decodedResponse.items[0]
        XCTAssertEqual(item1.id, "item-1")
        XCTAssertEqual(item1.type, "SKIN")
        XCTAssertEqual(item1.info, "Special edition")

        let item2 = decodedResponse.items[1]
        XCTAssertEqual(item2.id, "item-2")
        XCTAssertEqual(item2.type, "ICON")
        XCTAssertNil(item2.info)
    }

    func testStoreItemMapperToDomain() throws {
        let dto = StoreItemResponseDTO(
            id: "abc",
            name: "Theme 1",
            description: "Desc",
            image: "img.png",
            info: nil,
            price: 50,
            version: "1.1",
            type: "THEME"
        )

        let domainItem = StoreItemMapper.map(dto)
        XCTAssertEqual(domainItem.id, "abc")
        XCTAssertEqual(domainItem.name, "Theme 1")
        XCTAssertEqual(domainItem.type, "THEME")
        XCTAssertNil(domainItem.info)
    }

    func testGamificationEndpointQueryParameters() {
        let endpointFrame = GamificationEndpoint.getStoreItems(type: "FRAME")
        XCTAssertEqual(endpointFrame.path, "/store/items")
        XCTAssertEqual(endpointFrame.queryParameters, ["type": "FRAME"])

        let endpointSkin = GamificationEndpoint.getStoreItems(type: "SKIN")
        XCTAssertEqual(endpointSkin.queryParameters, ["type": "SKIN"])

        let endpointTheme = GamificationEndpoint.getStoreItems(type: "THEME")
        XCTAssertEqual(endpointTheme.queryParameters, ["type": "THEME"])

        let endpointIcon = GamificationEndpoint.getStoreItems(type: "ICON")
        XCTAssertEqual(endpointIcon.queryParameters, ["type": "ICON"])
    }
}
