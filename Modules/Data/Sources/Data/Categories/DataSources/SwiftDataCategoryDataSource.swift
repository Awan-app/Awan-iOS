import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataCategoryDataSource: LocalCategoryDataSource {
    public func fetchCategories() throws -> [TaskCategory] {
        try modelContext.fetch(FetchDescriptor<CategoryModel>())
            .map { TaskCategory(id: $0.id, name: $0.name) }
            .sorted(by: Self.isOrdered)
    }

    public func replaceCategories(_ categories: [TaskCategory]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<CategoryModel>())
        let desiredIDs = Set(categories.map(\.id))
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for model in existing where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for category in categories {
            if let model = existingByID[category.id] {
                model.name = category.name
            } else {
                modelContext.insert(CategoryModel(id: category.id, name: category.name))
            }
        }
        try modelContext.save()
    }

    public func upsertCategory(_ category: TaskCategory) throws {
        let targetID = category.id
        var descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        if let model = try modelContext.fetch(descriptor).first {
            model.name = category.name
        } else {
            modelContext.insert(CategoryModel(id: category.id, name: category.name))
        }
        try modelContext.save()
    }

    public func deleteCategory(id: UUID) throws {
        let targetID = id
        var descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            try modelContext.save()
        }
    }

    private static func isOrdered(_ lhs: TaskCategory, _ rhs: TaskCategory) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
