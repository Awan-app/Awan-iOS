import AwaNetwork

public protocol RemoteCategoryDataSource: Sendable {
    func listCategories() async throws -> [CategoryResponseDTO]
    func createCategory(_ request: CreateCategoryRequestDTO) async throws -> CategoryResponseDTO
}

public final class DefaultRemoteCategoryDataSource: RemoteCategoryDataSource {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func listCategories() async throws -> [CategoryResponseDTO] {
        try await networkService.request(CategoryEndpoint.list)
    }

    public func createCategory(
        _ request: CreateCategoryRequestDTO
    ) async throws -> CategoryResponseDTO {
        try await networkService.request(CategoryEndpoint.create(request))
    }
}
