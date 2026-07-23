import Foundation

public protocol UpdateTemplateUseCase: Sendable {
    func execute(id: UUID, zones: [Zone]) async throws -> Template
}

public struct DefaultUpdateTemplateUseCase: UpdateTemplateUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, zones: [Zone]) async throws -> Template {
        try await repository.updateTemplate(id: id, zones: zones)
    }
}
