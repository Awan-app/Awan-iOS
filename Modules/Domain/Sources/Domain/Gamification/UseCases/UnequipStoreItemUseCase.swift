//
//  UnequipStoreItemUseCase.swift
//  Domain
//

import Foundation

public protocol UnequipStoreItemUseCase: Sendable {
    func execute(type: StoreItemType) async throws
}

public struct DefaultUnequipStoreItemUseCase: UnequipStoreItemUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute(type: StoreItemType) async throws {
        try await repository.unequipStoreItem(type: type)
    }
}
