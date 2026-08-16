import Foundation

public protocol DeleteCategoryUseCase: Sendable {
    func execute(id: UUID) async throws
}

public struct DefaultDeleteCategoryUseCase: DeleteCategoryUseCase {
    private let repository: any CategoryRepository

    public init(repository: any CategoryRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteCategory(id: id)
    }
}
