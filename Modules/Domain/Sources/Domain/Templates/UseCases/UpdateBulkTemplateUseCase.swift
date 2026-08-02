import Foundation

public protocol UpdateTemplateUseCase: Sendable {
    func execute(id: UUID, zones: [TemplateZoneMutation]) async throws -> Template
}

public struct DefaultBulkUpdateTemplateUseCase: UpdateTemplateUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, zones: [TemplateZoneMutation]) async throws -> Template {
        try await repository.updateBulkTemplate(id: id, zones: zones)
    }
}
