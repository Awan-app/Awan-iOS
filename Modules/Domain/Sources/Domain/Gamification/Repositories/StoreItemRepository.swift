//
//  StoreItemRepository.swift
//  Domain
//

import Foundation

public protocol StoreItemRepository: Sendable {
    func fetchStoreItems(type: String) async throws -> [StoreItem]
}
