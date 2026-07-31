import Foundation

public protocol CreateTemplateOverrideUseCase: Sendable {
    func execute(name: String?, dateOfDay: String, zones: [Zone]?) async throws -> TemplateOverride
}

public struct DefaultCreateTemplateOverrideUseCase: CreateTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(name: String?, dateOfDay: String, zones: [Zone]?) async throws -> TemplateOverride {
        try await repository.createTemplateOverride(name: name, dateOfDay: dateOfDay, zones: zones)
    }
}
