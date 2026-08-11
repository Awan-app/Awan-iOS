//
//  UnequipStoreItemUseCase.swift
//  Domain
//

import Foundation

public protocol UnequipStoreItemUseCase: Sendable {
    func execute(type: String) async throws
}

public struct DefaultUnequipStoreItemUseCase: UnequipStoreItemUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute(type: String) async throws {
        try await repository.unequipStoreItem(type: type)
    }
}
