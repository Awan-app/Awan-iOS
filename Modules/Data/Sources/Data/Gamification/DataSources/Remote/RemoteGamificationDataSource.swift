//
//  RemoteGamificationDataSource.swift
//  Data
//

import AwaNetwork

public protocol RemoteGamificationDataSource: Sendable {
    func getProgress() async throws -> UserProgressResponseDTO
    func getWheelConfig() async throws -> DailyWheelConfigResponseDTO
    func spinWheel() async throws -> DailyWheelSpinResponseDTO
    func getStoreItems(type: String) async throws -> [StoreItemResponseDTO]
    func buyStoreItem(itemID: String) async throws -> StorePurchaseResponseDTO
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
    public func getStoreItems(type: String) async throws -> [StoreItemResponseDTO] {
        let response: StoreItemsResponseDTO = try await networkService.request(
            GamificationEndpoint.getStoreItems(type: type)
        )
        return response.items
    }

    public func buyStoreItem(itemID: String) async throws -> StorePurchaseResponseDTO {
        try await networkService.request(
            GamificationEndpoint.buyStoreItem(itemID: itemID)
        )
    }
}
