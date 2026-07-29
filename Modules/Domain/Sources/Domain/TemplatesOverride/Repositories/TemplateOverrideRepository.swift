import Foundation

public protocol TemplateOverrideRepository: Sendable {
    func updateBulkTemplateOverride(id: UUID, zones: [Zone]) async throws -> [Zone]
    func deleteTemplateOverride(id: UUID) async throws
}
