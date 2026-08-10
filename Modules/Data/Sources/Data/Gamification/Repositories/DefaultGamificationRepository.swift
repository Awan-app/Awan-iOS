//
//  DefaultGamificationRepository.swift
//  Data
//

import AwaNetwork
import Domain

public final class DefaultGamificationRepository: GamificationRepository {
    private let remoteDataSource: any RemoteGamificationDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    
    public init(
        remoteDataSource: any RemoteGamificationDataSource,
        localProfileDataSource: any LocalUserProfileDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localProfileDataSource = localProfileDataSource
    }
    public func fetchStoreItems(type: String) async throws -> [StoreItem] {
        let dtos = try await remoteDataSource.getStoreItems(type: type)
        return StoreItemMapper.map(dtos)
    }
    
    public func buyStoreItem(itemID: String) async throws -> StorePurchase {
        do {
            let dto = try await remoteDataSource.buyStoreItem(itemID: itemID)
            return StorePurchaseMapper.map(dto)
        } catch {
            throw map(error)
        }
    }

    public func equipStoreItem(itemID: String) async throws -> EquippedItem {
        do {
            let dto = try await remoteDataSource.equipStoreItem(itemID: itemID)
            return EquippedItemMapper.map(dto)
        } catch {
            throw map(error)
        }
    }

    public func fetchEquippedItems() async throws -> [EquippedItem] {
        do {
            let dtos = try await remoteDataSource.getEquippedItems()
            return dtos.map { EquippedItemMapper.map($0) }
        } catch {
            throw map(error)
        }
    }

    public func fetchUserPoints() async throws -> Int {
        let dto = try await remoteDataSource.getProgress()
        return dto.points
    }

    public func fetchWheelConfig() async throws -> DailyWheelConfiguration {
        do {
            return try DailyWheelMapper.configuration(
                await remoteDataSource.getWheelConfig()
            )
        } catch {
            throw map(error)
        }
    }

    public func spinWheel() async throws -> DailyWheelSpinResult {
        do {
            let result = try DailyWheelMapper.spinResult(
                await remoteDataSource.spinWheel()
            )

            // The reward is already committed remotely. Cache synchronization
            // must never turn that success into a retryable spin failure.
            try? await localProfileDataSource.updatePoints(result.newBalance)
            return result
        } catch {
            throw map(error)
        }
    }

    private func map(_ error: any Error) -> any Error {
        if error is CancellationError {
            return CancellationError()
        }

        if let error = error as? GamificationError {
            return error
        }

        guard case let NetworkError.httpError(statusCode, apiError) = error else {
            return GamificationError.unavailable(error.localizedDescription)
        }

        if statusCode == 409 {
            if apiError?.errorCode == .dailyGiftAlreadyClaimed {
                return GamificationError.alreadyClaimed
            }
            return GamificationError.itemNotOwned
        }

        if statusCode == 404 {
            return GamificationError.itemNotFound
        }

        if statusCode == 401 {
            return GamificationError.authenticationFailed
        }

        switch apiError?.errorCode {
        case .insufficientPoints:
            return GamificationError.insufficientPoints
        case .itemNotOwned:
            return GamificationError.itemNotOwned
        case .itemNotFound:
            return GamificationError.itemNotFound
        case .userNotFound:
            return GamificationError.userNotFound
        case .refreshTokenInvalid, .refreshTokenExpired, .refreshTokenReuseDetected:
            return GamificationError.authenticationFailed
        default:
            return GamificationError.unavailable(
                apiError?.message ?? error.localizedDescription
            )
        }
    }
}

