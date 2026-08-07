public protocol CreateCategoryUseCase: Sendable {
    func execute(name: String) async throws -> TaskCategory
}

public struct DefaultCreateCategoryUseCase: CreateCategoryUseCase {
    private let repository: any CategoryRepository

    public init(repository: any CategoryRepository) {
        self.repository = repository
    }

    public func execute(name: String) async throws -> TaskCategory {
        try await repository.createCategory(name: name)
    }
}
