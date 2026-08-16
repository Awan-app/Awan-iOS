import Foundation

public protocol UpdateCategoryUseCase: Sendable {
    func execute(id: UUID, name: String) async throws -> TaskCategory
}

public struct DefaultUpdateCategoryUseCase: UpdateCategoryUseCase {
    private let repository: any CategoryRepository

    public init(repository: any CategoryRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, name: String) async throws -> TaskCategory {
        try await repository.updateCategory(id: id, name: name)
    }
}
