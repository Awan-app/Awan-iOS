import Combine
import Domain

public struct DefaultCategoryRepository: CategoryRepository {
    private let localDataSource: any LocalCategoryDataSource
    private let remoteDataSource: any RemoteCategoryDataSource

    public init(
        localDataSource: any LocalCategoryDataSource,
        remoteDataSource: any RemoteCategoryDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func observeCategories() -> AnyPublisher<[TaskCategory], Error> {
        let cached = AsyncValuePublisher.make {
            try await localDataSource.fetchCategories()
        }
        let remote = AsyncValuePublisher.make {
            try await refreshCategories()
        }
        return cached
            .catch { _ in Just<[TaskCategory]>([]) }
            .setFailureType(to: Error.self)
            .append(remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func createCategory(name: String) async throws -> TaskCategory {
        let response = try await remoteDataSource.createCategory(
            CreateCategoryRequestDTO(name: name)
        )
        let category = TaskCategory(id: response.id, name: response.name)
        try await localDataSource.upsertCategory(category)
        return category
    }

    private func refreshCategories() async throws -> [TaskCategory] {
        let categories = try await remoteDataSource.listCategories()
            .map { TaskCategory(id: $0.id, name: $0.name) }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        try await localDataSource.replaceCategories(categories)
        return categories
    }
}
