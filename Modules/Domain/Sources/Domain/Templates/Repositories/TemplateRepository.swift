import Foundation

public protocol TemplateRepository: Sendable {
    func createTemplate(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template
    func listTemplates() async throws -> [Template]
    func updateBulkTemplate(id: UUID, zones: [TemplateZoneMutation]) async throws -> Template
    func updateTemplate(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template
    func deleteTemplate(id: UUID) async throws
}

public extension TemplateRepository {
    func createWeeklyTemplate(zones: [Zone]) async throws {
        _ = try await createTemplate(
            name: "Default",
            daysOfWeek: Set(TemplateWeekday.allCases),
            zones: zones
        )
    }
}
