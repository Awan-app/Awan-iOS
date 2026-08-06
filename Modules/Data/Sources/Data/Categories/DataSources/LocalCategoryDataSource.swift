import Domain

public protocol LocalCategoryDataSource: Sendable {
    func fetchCategories() async throws -> [TaskCategory]
    func replaceCategories(_ categories: [TaskCategory]) async throws
    func upsertCategory(_ category: TaskCategory) async throws
}
