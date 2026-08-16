import Combine
import Foundation

public protocol CategoryRepository: Sendable {
    func observeCategories() -> AnyPublisher<[TaskCategory], Error>
    func createCategory(name: String) async throws -> TaskCategory
    func updateCategory(id: UUID, name: String) async throws -> TaskCategory
    func deleteCategory(id: UUID) async throws
}

