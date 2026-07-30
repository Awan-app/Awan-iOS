import Foundation

public protocol UpdateTemplateDetailsUseCase: Sendable {
    func execute(id: UUID, name: String, daysOfWeek: [String]) async throws -> Template
}

public struct DefaultUpdateTemplateDetailsUseCase: UpdateTemplateDetailsUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, name: String, daysOfWeek: [String]) async throws -> Template {
        try await repository.updateTemplate(id: id, name: name, daysOfWeek: daysOfWeek)
    }
}
