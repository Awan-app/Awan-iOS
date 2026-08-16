import AwaNetwork
import Foundation

public protocol RemoteCategoryDataSource: Sendable {
    func listCategories() async throws -> [CategoryResponseDTO]
    func createCategory(_ request: CreateCategoryRequestDTO) async throws -> CategoryResponseDTO
    func updateCategory(id: UUID, _ request: UpdateCategoryRequestDTO) async throws -> CategoryResponseDTO
    func deleteCategory(id: UUID) async throws
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

    public func updateCategory(
        id: UUID,
        _ request: UpdateCategoryRequestDTO
    ) async throws -> CategoryResponseDTO {
        try await networkService.request(CategoryEndpoint.update(id: id, request: request))
    }

    public func deleteCategory(id: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(CategoryEndpoint.delete(id: id))
    }
}

