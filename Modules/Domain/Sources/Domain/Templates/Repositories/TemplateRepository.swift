import Foundation

public protocol TemplateRepository: Sendable {
    func createWeeklyTemplate(zones: [Zone]) async throws
    func listTemplates() async throws -> [Template]
    func updateTemplate(id: UUID, zones: [Zone]) async throws -> Template
}
