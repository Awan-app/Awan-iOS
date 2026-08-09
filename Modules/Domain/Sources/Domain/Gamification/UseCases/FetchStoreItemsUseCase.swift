//
//  FetchStoreItemsUseCase.swift
//  Domain
//

import Foundation

public protocol FetchStoreItemsUseCase: Sendable {
    func execute(type: String) async throws -> [StoreItem]
}

public struct DefaultFetchStoreItemsUseCase: FetchStoreItemsUseCase {
    private let repository: any StoreItemRepository

    public init(repository: any StoreItemRepository) {
        self.repository = repository
    }

    public func execute(type: String) async throws -> [StoreItem] {
        try await repository.fetchStoreItems(type: type)
    }
}
