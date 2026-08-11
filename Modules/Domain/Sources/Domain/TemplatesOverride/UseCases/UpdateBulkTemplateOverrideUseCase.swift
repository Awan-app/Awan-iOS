import Foundation

public protocol UpdateBulkTemplateOverrideUseCase: Sendable {
    func execute(id: UUID, zones: [TemplateZoneMutation]) async throws -> TemplateOverride
}

public struct DefaultUpdateBulkTemplateOverrideUseCase: UpdateBulkTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> TemplateOverride {
        try await repository.updateBulkTemplateOverride(id: id, zones: zones)
    }
}
