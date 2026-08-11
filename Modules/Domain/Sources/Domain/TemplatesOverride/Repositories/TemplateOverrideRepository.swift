import Foundation

public protocol TemplateOverrideRepository: Sendable {
    func createTemplateOverride(
        name: String,
        dateOfDay: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride
    func listTemplateOverrides() async throws -> [TemplateOverride]
    func updateTemplateOverride(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate
    ) async throws -> TemplateOverride
    func updateBulkTemplateOverride(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> TemplateOverride
    func deleteTemplateOverride(id: UUID) async throws
}
