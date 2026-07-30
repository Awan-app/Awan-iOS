import Foundation

public protocol UpdateBulkTemplateOverrideUseCase: Sendable {
    func execute(id: UUID, zones: [Zone]) async throws -> [Zone]
}

public struct DefaultUpdateBulkTemplateOverrideUseCase: UpdateBulkTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, zones: [Zone]) async throws -> [Zone] {
        try await repository.updateBulkTemplateOverride(id: id, zones: zones)
    }
}
