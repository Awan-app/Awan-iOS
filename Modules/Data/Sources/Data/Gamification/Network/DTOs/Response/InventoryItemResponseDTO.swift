//
//  InventoryItemResponseDTO.swift
//  Data
//

import Foundation

public struct InventoryItemResponseDTO: Decodable, Equatable, Sendable {
    public let id: String
    public let item: StoreItemResponseDTO
    public let boughtAt: String

    public init(id: String, item: StoreItemResponseDTO, boughtAt: String) {
        self.id = id
        self.item = item
        self.boughtAt = boughtAt
    }
}
