import Foundation

public protocol UpdateTemplateOverrideUseCase: Sendable {
    func execute(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate
    ) async throws -> TemplateOverride
}

public struct DefaultUpdateTemplateOverrideUseCase: UpdateTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate
    ) async throws -> TemplateOverride {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw TemplateManagementError.overrideNameRequired
        }
        guard dateOfDay >= minimumDate else {
            throw TemplateManagementError.overrideDateInPast
        }
        let overrides = try await repository.listTemplateOverrides()
        guard !overrides.contains(where: { $0.id != id && $0.dateOfDay == dateOfDay }) else {
            throw TemplateManagementError.overrideDateAlreadyExists
        }
        return try await repository.updateTemplateOverride(id: id, name: name, dateOfDay: dateOfDay)
    }
}
