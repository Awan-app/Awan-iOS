import Foundation

public protocol DeleteTemplateUseCase: Sendable {
    func execute(id: UUID) async throws
}

public struct DefaultDeleteTemplateUseCase: DeleteTemplateUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteTemplate(id: id)
    }
}
