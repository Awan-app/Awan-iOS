import Foundation

public protocol UpdateTemplateOverrideUseCase: Sendable {
    func execute(id: UUID, name: String?, dateOfDay: String) async throws -> TemplateOverride
}

public struct DefaultUpdateTemplateOverrideUseCase: UpdateTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, name: String?, dateOfDay: String) async throws -> TemplateOverride {
        try await repository.updateTemplateOverride(id: id, name: name, dateOfDay: dateOfDay)
    }
}
