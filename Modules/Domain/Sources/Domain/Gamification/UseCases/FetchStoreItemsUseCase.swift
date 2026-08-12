//
//  FetchStoreItemsUseCase.swift
//  Domain
//

import Combine
import Foundation

public protocol FetchStoreItemsUseCase: Sendable {
    func execute() async throws -> [StoreItem]
    func observe() -> AnyPublisher<[StoreItem], Error>
}

public extension FetchStoreItemsUseCase {
    func observe() -> AnyPublisher<[StoreItem], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchStoreItemsUseCase: FetchStoreItemsUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func observe() -> AnyPublisher<[StoreItem], Error> {
        repository.observeStoreItems()
    }

    public func execute() async throws -> [StoreItem] {
        try await repository.fetchStoreItems()
    }
}
