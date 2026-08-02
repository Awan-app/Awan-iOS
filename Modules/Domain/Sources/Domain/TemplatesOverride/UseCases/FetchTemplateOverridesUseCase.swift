public protocol FetchTemplateOverridesUseCase: Sendable {
    func execute() async throws -> [TemplateOverride]
}

public struct DefaultFetchTemplateOverridesUseCase: FetchTemplateOverridesUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [TemplateOverride] {
        try await repository.listTemplateOverrides()
    }
}
