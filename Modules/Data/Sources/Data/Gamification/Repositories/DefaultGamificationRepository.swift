//
//  DefaultGamificationRepository.swift
//  Data
//

import AwaNetwork
import Combine
import Domain

public final class DefaultGamificationRepository: GamificationRepository {
    private let remoteDataSource: any RemoteGamificationDataSource
    private let localGamificationDataSource: any LocalGamificationDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    
    public init(
        remoteDataSource: any RemoteGamificationDataSource,
        localGamificationDataSource: any LocalGamificationDataSource,
        localProfileDataSource: any LocalUserProfileDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localGamificationDataSource = localGamificationDataSource
        self.localProfileDataSource = localProfileDataSource
    }
    public func fetchStoreItems() async throws -> [StoreItem] {
        try await localGamificationDataSource.fetchStoreItems()
    }

    public func observeStoreItems() -> AnyPublisher<[StoreItem], Error> {
        let local = localGamificationDataSource.observeStoreItems()
        let remote = AsyncValuePublisher.make { try await self.refreshStoreItems() }
            .catch { _ in Empty<[StoreItem], Error>() }
            .eraseToAnyPublisher()
        return local
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func buyStoreItem(itemID: String) async throws -> StorePurchase {
        do {
            let dto = try await remoteDataSource.buyStoreItem(itemID: itemID)
            let purchase = StorePurchaseMapper.map(dto)
            let inventoryItem = InventoryItem(
                id: purchase.id,
                item: purchase.item,
                boughtAt: purchase.boughtAt
            )
            try await localGamificationDataSource.upsertInventoryItem(inventoryItem)

            if let progress = try? await remoteDataSource.getProgress() {
                try? await localProfileDataSource.updatePoints(progress.points)
            }

            return purchase
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

    public func unequipStoreItem(type: StoreItemType) async throws {
        do {
            try await remoteDataSource.unequipStoreItem(type: type.rawValue)
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

    public func fetchStoreInventory() async throws -> [InventoryItem] {
        try await localGamificationDataSource.fetchInventoryItems()
    }

    public func observeStoreInventory() -> AnyPublisher<[InventoryItem], Error> {
        let local = localGamificationDataSource.observeInventoryItems()
        let remote = AsyncValuePublisher.make { try await self.refreshStoreInventory() }
            .catch { _ in Empty<[InventoryItem], Error>() }
            .eraseToAnyPublisher()
        return local
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func refreshStoreItems() async throws -> [StoreItem] {
        let items = StoreItemMapper.map(try await remoteDataSource.getStoreItems())
            .sorted { $0.id < $1.id }
        try await localGamificationDataSource.replaceStoreItems(items)
        return items
    }

    private func refreshStoreInventory() async throws -> [InventoryItem] {
        do {
            let dtos = try await remoteDataSource.getStoreInventory()
            let items = dtos.map { InventoryItemMapper.map($0) }
                .sorted { $0.boughtAt > $1.boughtAt }
            try await localGamificationDataSource.replaceInventoryItems(items)
            return items
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

    public func fetchActivityDays(
        from startDay: ActivityDay,
        through endDay: ActivityDay
    ) async throws -> Set<ActivityDay> {
        do {
            let calendar = ActivityDayMapper.gregorianCalendar

            let requestedStart = try ActivityDayMapper.date(from: startDay)
            let requestedEnd = try ActivityDayMapper.date(from: endDay)

            guard requestedStart <= requestedEnd else {
                throw GamificationError.invalidActivityRange
            }

            guard let dayDifference = calendar.dateComponents(
                [.day],
                from: requestedStart,
                to: requestedEnd
            ).day else {
                throw GamificationError.invalidActivityRange
            }

            let inclusiveDayCount = dayDifference + 1

            guard inclusiveDayCount <= 31 else {
                throw GamificationError.invalidActivityRange
            }

            let response = try await remoteDataSource.getActivityDates(
                startDate: ActivityDayMapper.string(from: startDay),
                endDate: ActivityDayMapper.string(from: endDay)
            )

            return try ActivityDayMapper.map(response)

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

        if statusCode == 400 || apiError?.errorCode == .typeMismatch {
            return GamificationError.typeMismatch
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
        case .typeMismatch:
            return GamificationError.typeMismatch
        case .refreshTokenInvalid, .refreshTokenExpired, .refreshTokenReuseDetected:
            return GamificationError.authenticationFailed
        default:
            return GamificationError.unavailable(
                apiError?.message ?? error.localizedDescription
            )
        }
    }
}
