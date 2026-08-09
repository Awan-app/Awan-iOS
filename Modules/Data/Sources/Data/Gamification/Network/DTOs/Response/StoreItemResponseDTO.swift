//
//  StoreItemResponseDTO.swift
//  Data
//

import Foundation

public struct StoreItemResponseDTO: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let image: String
    public let info: String?
    public let price: Int
    public let version: String
    public let type: String

    public init(
        id: String,
        name: String,
        description: String,
        image: String,
        info: String?,
        price: Int,
        version: String,
        type: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.info = info
        self.price = price
        self.version = version
        self.type = type
    }
}

public struct StoreItemsResponseDTO: Decodable, Equatable, Sendable {
    public let items: [StoreItemResponseDTO]

    public init(items: [StoreItemResponseDTO]) {
        self.items = items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleItem = try? container.decode(StoreItemResponseDTO.self) {
            self.items = [singleItem]
        } else {
            self.items = try container.decode([StoreItemResponseDTO].self)
        }
    }
}
