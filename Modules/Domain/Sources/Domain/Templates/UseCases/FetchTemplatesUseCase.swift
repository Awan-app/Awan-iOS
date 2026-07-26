import Foundation

public protocol FetchTemplatesUseCase: Sendable {
    func execute() async throws -> [Template]
}

public struct DefaultFetchTemplatesUseCase: FetchTemplatesUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Template] {
        try await repository.listTemplates()
    }
}
