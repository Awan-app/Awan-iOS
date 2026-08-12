//
//  RemoteGamificationDataSource.swift
//  Data
//

import AwaNetwork

public protocol RemoteGamificationDataSource: Sendable {
    func getProgress() async throws -> UserProgressResponseDTO
    func getWheelConfig() async throws -> DailyWheelConfigResponseDTO
    func spinWheel() async throws -> DailyWheelSpinResponseDTO
    func getStoreItems() async throws -> [StoreItemResponseDTO]
    func buyStoreItem(itemID: String) async throws -> StorePurchaseResponseDTO
    func equipStoreItem(itemID: String) async throws -> EquippedItemResponseDTO
    func unequipStoreItem(type: String) async throws
    func getEquippedItems() async throws -> [EquippedItemResponseDTO]
    func getStoreInventory() async throws -> [InventoryItemResponseDTO]
    func getActivityDates(startDate: String, endDate: String) async throws -> [String]
}

public final class DefaultRemoteGamificationDataSource:
    RemoteGamificationDataSource {

    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getProgress() async throws -> UserProgressResponseDTO {
        try await networkService.request(
            GamificationEndpoint.getProgress
        )
    }

    public func getWheelConfig() async throws -> DailyWheelConfigResponseDTO {
        try await networkService.request(GamificationEndpoint.getWheelConfig)
    }

    public func spinWheel() async throws -> DailyWheelSpinResponseDTO {
        try await networkService.request(GamificationEndpoint.spinWheel)
    }

    public func getStoreItems() async throws -> [StoreItemResponseDTO] {
        let response: StoreItemsResponseDTO = try await networkService.request(
            GamificationEndpoint.getStoreItems
        )
        return response.items
    }

    public func buyStoreItem(itemID: String) async throws -> StorePurchaseResponseDTO {
        try await networkService.request(
            GamificationEndpoint.buyStoreItem(itemID: itemID)
        )
    }

    public func equipStoreItem(itemID: String) async throws -> EquippedItemResponseDTO {
        try await networkService.request(
            GamificationEndpoint.equipStoreItem(itemID: itemID)
        )
    }

    public func unequipStoreItem(type: String) async throws {
        let _: EmptyResponse = try await networkService.request(
            GamificationEndpoint.unequipStoreItem(type: type)
        )
    }

    public func getEquippedItems() async throws -> [EquippedItemResponseDTO] {
        try await networkService.request(
            GamificationEndpoint.getEquippedItems
        )
    }

    public func getStoreInventory() async throws -> [InventoryItemResponseDTO] {
        try await networkService.request(GamificationEndpoint.getStoreInventory)
    }
    
    public func getActivityDates(
        startDate: String,
        endDate: String
    ) async throws -> [String] {
        try await networkService.request(
            GamificationEndpoint.activityDates(
                startDate: startDate,
                endDate: endDate
            )
        )
    }
}
