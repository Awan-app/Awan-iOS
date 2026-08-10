//
//  EquipStoreItemUseCase.swift
//  Domain
//

import Foundation

public protocol EquipStoreItemUseCase: Sendable {
    func execute(itemID: String) async throws -> EquippedItem
}

public struct DefaultEquipStoreItemUseCase: EquipStoreItemUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute(itemID: String) async throws -> EquippedItem {
        try await repository.equipStoreItem(itemID: itemID)
    }
}
