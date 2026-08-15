//
//  StorePurchase.swift
//  Domain
//

import Foundation

public struct StorePurchase: Identifiable, Equatable, Sendable {
    public let id: String
    public let item: StoreItem
    public let boughtAt: Date

    public init(id: String, item: StoreItem, boughtAt: Date) {
        self.id = id
        self.item = item
        self.boughtAt = boughtAt
    }
}
