//
//  FetchStoreInventoryUseCase.swift
//  Domain
//

import Combine
import Foundation

public protocol FetchStoreInventoryUseCase: Sendable {
    func execute() async throws -> [InventoryItem]
    func observe() -> AnyPublisher<[InventoryItem], Error>
}

public extension FetchStoreInventoryUseCase {
    func observe() -> AnyPublisher<[InventoryItem], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchStoreInventoryUseCase: FetchStoreInventoryUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func observe() -> AnyPublisher<[InventoryItem], Error> {
        repository.observeStoreInventory()
    }

    public func execute() async throws -> [InventoryItem] {
        try await repository.fetchStoreInventory()
    }
}
