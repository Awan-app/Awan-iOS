//
//  DefaultStoreItemRepository.swift
//  Data
//

import Domain

public final class DefaultStoreItemRepository: StoreItemRepository {
    private let remoteDataSource: any RemoteGamificationDataSource

    public init(remoteDataSource: any RemoteGamificationDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchStoreItems(type: String) async throws -> [StoreItem] {
        let dtos = try await remoteDataSource.getStoreItems(type: type)
        return StoreItemMapper.map(dtos)
    }
}
