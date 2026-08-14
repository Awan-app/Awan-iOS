//
//  InventoryItemDecodingTests.swift
//  DataTests
//

import Data
import Domain
import XCTest

final class InventoryItemDecodingTests: XCTestCase {
    func testInventoryItemResponseDTODecoding() throws {
        let json = """
        {
            "id": "inv-100",
            "item": {
                "id": "item-gold-frame",
                "name": "Gold Frame",
                "description": "Shiny frame",
                "image": "https://example.com/frame.png",
                "info": null,
                "price": 100,
                "version": "1.0",
                "type": "FRAME"
            },
            "boughtAt": "2026-07-22T10:00:00Z"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(InventoryItemResponseDTO.self, from: json)

        XCTAssertEqual(dto.id, "inv-100")
        XCTAssertEqual(dto.item.id, "item-gold-frame")
        XCTAssertEqual(dto.item.name, "Gold Frame")
        XCTAssertEqual(dto.item.type, "FRAME")
        XCTAssertEqual(dto.boughtAt, "2026-07-22T10:00:00Z")
    }

    func testInventoryItemMapper() throws {
        let dto = InventoryItemResponseDTO(
            id: "inv-100",
            item: StoreItemResponseDTO(
                id: "item-gold-frame",
                name: "Gold Frame",
                description: "Shiny frame",
                image: "https://example.com/frame.png",
                info: nil,
                price: 100,
                version: "1.0",
                type: "FRAME"
            ),
            boughtAt: "2026-07-22T10:00:00Z"
        )

        let domainModel = InventoryItemMapper.map(dto)

        XCTAssertEqual(domainModel.id, "inv-100")
        XCTAssertEqual(domainModel.item.id, "item-gold-frame")
        XCTAssertEqual(domainModel.item.name, "Gold Frame")
        XCTAssertEqual(domainModel.item.type, .frame)
    }
}
