//
//  GamificationRepository.swift
//  Domain
//

import Combine
import Foundation

public protocol GamificationRepository: Sendable {
    func fetchStoreItems() async throws -> [StoreItem]
    func observeStoreItems() -> AnyPublisher<[StoreItem], Error>
    func buyStoreItem(itemID: String) async throws -> StorePurchase
    func equipStoreItem(itemID: String) async throws -> EquippedItem
    func unequipStoreItem(type: StoreItemType) async throws
    func fetchEquippedItems() async throws -> [EquippedItem]
    func fetchStoreInventory() async throws -> [InventoryItem]
    func observeStoreInventory() -> AnyPublisher<[InventoryItem], Error>
    func fetchUserPoints() async throws -> Int
    func fetchWheelConfig() async throws -> DailyWheelConfiguration
    func spinWheel() async throws -> DailyWheelSpinResult

    func fetchActivityDays(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay>
}

public extension GamificationRepository {
    func observeStoreItems() -> AnyPublisher<[StoreItem], Error> {
        AsyncValuePublisher.make { try await fetchStoreItems() }
    }

    func observeStoreInventory() -> AnyPublisher<[InventoryItem], Error> {
        AsyncValuePublisher.make { try await fetchStoreInventory() }
    }
}
