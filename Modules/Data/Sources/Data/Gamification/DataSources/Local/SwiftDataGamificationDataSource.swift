import Combine
import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataGamificationDataSource: LocalGamificationDataSource {
    private let storeItemChanges = LocalDataObservationHub()
    private let inventoryChanges = LocalDataObservationHub()

    public nonisolated func observeStoreItems() -> AnyPublisher<[StoreItem], Error> {
        storeItemChanges.publisher()
            .prepend(())
            .flatMap(maxPublishers: .max(1)) { [self] _ in
                AsyncValuePublisher.make { try await self.fetchStoreItems() }
            }
            .eraseToAnyPublisher()
    }

    public func fetchStoreItems() throws -> [StoreItem] {
        try modelContext.fetch(FetchDescriptor<StoreItemModel>())
            .map { $0.toDomain() }
            .sorted { $0.id < $1.id }
    }

    public func replaceStoreItems(_ items: [StoreItem]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<StoreItemModel>())
        let desiredIDs = Set(items.map(\.id))
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for model in existing where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for item in items {
            if let model = existingByID[item.id] {
                model.update(from: item)
            } else {
                modelContext.insert(StoreItemModel(item: item))
            }
        }
        try modelContext.save()
        storeItemChanges.send()
    }

    public nonisolated func observeInventoryItems() -> AnyPublisher<[InventoryItem], Error> {
        inventoryChanges.publisher()
            .prepend(())
            .flatMap(maxPublishers: .max(1)) { [self] _ in
                AsyncValuePublisher.make { try await self.fetchInventoryItems() }
            }
            .eraseToAnyPublisher()
    }

    public func fetchInventoryItems() throws -> [InventoryItem] {
        try modelContext.fetch(FetchDescriptor<InventoryItemModel>())
            .map { $0.toDomain() }
            .sorted { $0.boughtAt > $1.boughtAt }
    }

    public func replaceInventoryItems(_ items: [InventoryItem]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<InventoryItemModel>())
        let desiredIDs = Set(items.map(\.id))
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for model in existing where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for item in items {
            if let model = existingByID[item.id] {
                model.update(from: item)
            } else {
                modelContext.insert(InventoryItemModel(item: item))
            }
        }
        try modelContext.save()
        inventoryChanges.send()
    }

    public func upsertInventoryItem(_ item: InventoryItem) throws {
        let itemID = item.id
        var descriptor = FetchDescriptor<InventoryItemModel>(
            predicate: #Predicate { $0.id == itemID }
        )
        descriptor.fetchLimit = 1
        if let model = try modelContext.fetch(descriptor).first {
            model.update(from: item)
        } else {
            modelContext.insert(InventoryItemModel(item: item))
        }
        try modelContext.save()
        inventoryChanges.send()
    }
}
