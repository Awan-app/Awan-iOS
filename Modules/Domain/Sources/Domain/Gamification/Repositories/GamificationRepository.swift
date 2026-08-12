//
//  GamificationRepository.swift
//  Domain
//

import Foundation

public protocol GamificationRepository: Sendable {
    func fetchStoreItems() async throws -> [StoreItem]
    func buyStoreItem(itemID: String) async throws -> StorePurchase
    func equipStoreItem(itemID: String) async throws -> EquippedItem
    func unequipStoreItem(type: StoreItemType) async throws
    func fetchEquippedItems() async throws -> [EquippedItem]
    func fetchStoreInventory() async throws -> [InventoryItem]
    func fetchUserPoints() async throws -> Int
    func fetchWheelConfig() async throws -> DailyWheelConfiguration
    func spinWheel() async throws -> DailyWheelSpinResult

    func fetchActivityDays(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay>
}
