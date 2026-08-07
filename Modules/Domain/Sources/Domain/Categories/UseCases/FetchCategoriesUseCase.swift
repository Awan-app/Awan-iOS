import Combine

public protocol FetchCategoriesUseCase: Sendable {
    func observe() -> AnyPublisher<[TaskCategory], Error>
}

public struct DefaultFetchCategoriesUseCase: FetchCategoriesUseCase {
    private let repository: any CategoryRepository

    public init(repository: any CategoryRepository) {
        self.repository = repository
    }

    public func observe() -> AnyPublisher<[TaskCategory], Error> {
        repository.observeCategories()
    }
}
