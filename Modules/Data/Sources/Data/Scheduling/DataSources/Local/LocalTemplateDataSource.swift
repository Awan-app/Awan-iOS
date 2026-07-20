import Foundation

public protocol LocalTemplateDataSource: Sendable {
    func fetchTemplates() async throws -> [TemplateData]
    func fetchTemplate(forWeekDay weekDay: Int) async throws -> TemplateData?
    func addTemplate(_ template: TemplateData) async throws
    func updateTemplate(_ template: TemplateData) async throws
    func deleteTemplate(id: UUID) async throws
    func deleteAllTemplates() async throws
}
