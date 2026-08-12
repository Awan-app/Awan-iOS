//
//  FetchStoreItemsUseCase.swift
//  Domain
//

import Foundation

public protocol FetchStoreItemsUseCase: Sendable {
    func execute() async throws -> [StoreItem]
}

public struct DefaultFetchStoreItemsUseCase: FetchStoreItemsUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [StoreItem] {
        try await repository.fetchStoreItems()
    }
}
