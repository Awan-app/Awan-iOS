//
//  EquippedItemResponseDTO.swift
//  Data
//

import Foundation

public struct EquippedItemResponseDTO: Decodable, Equatable, Sendable {
    public let type: String
    public let item: StoreItemResponseDTO
    public let equippedAt: String

    public init(type: String, item: StoreItemResponseDTO, equippedAt: String) {
        self.type = type
        self.item = item
        self.equippedAt = equippedAt
    }
}
