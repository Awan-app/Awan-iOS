//
//  FetchEquippedItemsUseCase.swift
//  Domain
//

import Foundation

public protocol FetchEquippedItemsUseCase: Sendable {
    func execute() async throws -> [EquippedItem]
}

public struct DefaultFetchEquippedItemsUseCase: FetchEquippedItemsUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [EquippedItem] {
        try await repository.fetchEquippedItems()
    }
}
