import Foundation

public protocol CreateTemplateUseCase: Sendable {
    func execute(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template
}

public struct DefaultCreateTemplateUseCase: CreateTemplateUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw TemplateManagementError.templateNameRequired
        }
        guard !daysOfWeek.isEmpty else {
            throw TemplateManagementError.templateWeekdayRequired
        }
        return try await repository.createTemplate(
            name: name,
            daysOfWeek: daysOfWeek,
            zones: zones
        )
    }
}
