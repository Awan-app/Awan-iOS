import Domain
import Foundation

public protocol LocalCategoryDataSource: Sendable {
    func fetchCategories() async throws -> [TaskCategory]
    func replaceCategories(_ categories: [TaskCategory]) async throws
    func upsertCategory(_ category: TaskCategory) async throws
    func deleteCategory(id: UUID) async throws
}

