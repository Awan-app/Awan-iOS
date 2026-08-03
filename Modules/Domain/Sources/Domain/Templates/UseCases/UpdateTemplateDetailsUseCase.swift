import Foundation

public protocol UpdateTemplateDetailsUseCase: Sendable {
    func execute(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template
}

public struct DefaultUpdateTemplateDetailsUseCase: UpdateTemplateDetailsUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw TemplateManagementError.templateNameRequired
        }
        guard !daysOfWeek.isEmpty else {
            throw TemplateManagementError.templateWeekdayRequired
        }
        return try await repository.updateTemplate(id: id, name: name, daysOfWeek: daysOfWeek)
    }
}
