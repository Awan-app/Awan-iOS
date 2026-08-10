//
//  EquippedItem.swift
//  Domain
//

import Foundation

public struct EquippedItem: Identifiable, Equatable, Sendable {
    public var id: String { item.id }
    public let type: String
    public let item: StoreItem
    public let equippedAt: Date

    public init(type: String, item: StoreItem, equippedAt: Date) {
        self.type = type
        self.item = item
        self.equippedAt = equippedAt
    }
}
