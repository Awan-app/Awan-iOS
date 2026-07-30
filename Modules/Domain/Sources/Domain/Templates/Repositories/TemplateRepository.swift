import Foundation

public protocol TemplateRepository: Sendable {
    func createWeeklyTemplate(zones: [Zone]) async throws
    func listTemplates() async throws -> [Template]
    func updateBulkTemplate(id: UUID, zones: [ZoneWithoutId]) async throws -> Template
    func updateTemplate(id: UUID, name: String, daysOfWeek: [String]) async throws -> Template
    func deleteTemplate(id: UUID) async throws
}
