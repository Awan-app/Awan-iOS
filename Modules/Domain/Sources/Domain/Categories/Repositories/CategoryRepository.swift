import Combine

public protocol CategoryRepository: Sendable {
    func observeCategories() -> AnyPublisher<[TaskCategory], Error>
    func createCategory(name: String) async throws -> TaskCategory
}
