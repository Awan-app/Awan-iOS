import Domain
import Foundation

public protocol LocalTemplateOverrideDataSource: Sendable {
    func fetchTemplateOverrides() async throws -> [TemplateOverride]
    func addTemplateOverride(_ templateOverride: TemplateOverride) async throws
    func updateTemplateOverride(_ templateOverride: TemplateOverride) async throws
    func deleteTemplateOverride(id: UUID) async throws
    func deleteAllTemplateOverrides() async throws
}
