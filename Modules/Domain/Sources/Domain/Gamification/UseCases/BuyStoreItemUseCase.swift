//
//  BuyStoreItemUseCase.swift
//  Domain
//

import Foundation

public protocol BuyStoreItemUseCase: Sendable {
    func execute(itemID: String) async throws -> StorePurchase
}

public struct DefaultBuyStoreItemUseCase: BuyStoreItemUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute(itemID: String) async throws -> StorePurchase {
        try await repository.buyStoreItem(itemID: itemID)
    }
}
