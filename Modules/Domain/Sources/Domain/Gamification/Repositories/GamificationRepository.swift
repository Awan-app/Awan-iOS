//
//  GamificationRepository.swift
//  Domain
//

import Foundation

public protocol GamificationRepository: Sendable {
    func fetchStoreItems(type: String) async throws -> [StoreItem]
    func buyStoreItem(itemID: String) async throws -> StorePurchase
    func fetchUserPoints() async throws -> Int
}
