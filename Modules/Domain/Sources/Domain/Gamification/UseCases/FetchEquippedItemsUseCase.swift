//
//  FetchEquippedItemsUseCase.swift
//  Domain
//

import Combine
import Foundation

public protocol FetchEquippedItemsUseCase: Sendable {
    func execute() async throws -> [EquippedItem]
    func observeOrEmpty() -> AnyPublisher<[EquippedItem], Error>
}

public extension FetchEquippedItemsUseCase {
    func observeOrEmpty() -> AnyPublisher<[EquippedItem], Error> {
        AsyncValuePublisher.make { try await execute() }
            .prepend([])
            .replaceError(with: [])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
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
