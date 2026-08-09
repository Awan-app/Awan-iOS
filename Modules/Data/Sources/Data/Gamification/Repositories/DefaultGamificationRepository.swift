//
//  DefaultGamificationRepository.swift
//  Data
//

import AwaNetwork
import Domain

public final class DefaultGamificationRepository: GamificationRepository {
    private let remoteDataSource: any RemoteGamificationDataSource

    public init(remoteDataSource: any RemoteGamificationDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchStoreItems(type: String) async throws -> [StoreItem] {
        let dtos = try await remoteDataSource.getStoreItems(type: type)
        return StoreItemMapper.map(dtos)
    }

    public func buyStoreItem(itemID: String) async throws -> StorePurchase {
        do {
            let dto = try await remoteDataSource.buyStoreItem(itemID: itemID)
            return StorePurchaseMapper.map(dto)
        } catch let networkError as NetworkError {
            if case let .httpError(_, apiError) = networkError, apiError?.errorCode == .insufficientPoints {
                throw GamificationError.insufficientPoints
            }
            throw networkError
        } catch {
            throw error
        }
    }

    public func fetchUserPoints() async throws -> Int {
        let dto = try await remoteDataSource.getProgress()
        return dto.points
    }
}
