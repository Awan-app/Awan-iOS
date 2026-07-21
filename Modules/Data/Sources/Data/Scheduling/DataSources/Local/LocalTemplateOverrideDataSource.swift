import Foundation

public protocol LocalTemplateOverrideDataSource: Sendable {
    func fetchTemplateOverrides() async throws -> [TemplateOverrideData]
    func fetchTemplateOverride(for date: Date) async throws -> TemplateOverrideData?
    func addTemplateOverride(_ templateOverride: TemplateOverrideData) async throws
    func updateTemplateOverride(_ templateOverride: TemplateOverrideData) async throws
    func deleteTemplateOverride(id: UUID) async throws
    func deleteAllTemplateOverrides() async throws
}
