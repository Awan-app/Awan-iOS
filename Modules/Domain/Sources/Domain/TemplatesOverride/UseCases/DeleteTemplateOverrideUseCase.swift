import Foundation

public protocol DeleteTemplateOverrideUseCase: Sendable {
    func execute(id: UUID) async throws
}

public struct DefaultDeleteTemplateOverrideUseCase: DeleteTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.deleteTemplateOverride(id: id)
    }
}
