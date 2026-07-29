import Foundation

public protocol TemplateOverrideRepository: Sendable {
    func createTemplateOverride(name: String?, dateOfDay: String, zones: [Zone]?) async throws -> TemplateOverride
    func updateTemplateOverride(id: UUID, name: String?, dateOfDay: String) async throws -> TemplateOverride
    func updateBulkTemplateOverride(id: UUID, zones: [Zone]) async throws -> [Zone]
    func deleteTemplateOverride(id: UUID) async throws
}
