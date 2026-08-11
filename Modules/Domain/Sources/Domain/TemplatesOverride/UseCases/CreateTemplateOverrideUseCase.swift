import Foundation

public protocol CreateTemplateOverrideUseCase: Sendable {
    func execute(
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride
}

public struct DefaultCreateTemplateOverrideUseCase: CreateTemplateOverrideUseCase {
    private let repository: any TemplateOverrideRepository

    public init(repository: any TemplateOverrideRepository) {
        self.repository = repository
    }

    public func execute(
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw TemplateManagementError.overrideNameRequired
        }
        guard dateOfDay >= minimumDate else {
            throw TemplateManagementError.overrideDateInPast
        }
        let overrides = try await repository.listTemplateOverrides()
        guard !overrides.contains(where: { $0.dateOfDay == dateOfDay }) else {
            throw TemplateManagementError.overrideDateAlreadyExists
        }
        return try await repository.createTemplateOverride(
            name: name,
            dateOfDay: dateOfDay,
            zones: zones
        )
    }
}
