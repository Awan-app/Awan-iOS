//
//  FetchStoreInventoryUseCase.swift
//  Domain
//

import Foundation

public protocol FetchStoreInventoryUseCase: Sendable {
    func execute() async throws -> [InventoryItem]
}

public struct DefaultFetchStoreInventoryUseCase: FetchStoreInventoryUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [InventoryItem] {
        try await repository.fetchStoreInventory()
    }
}
