import Domain
import Foundation

public protocol LocalTemplateDataSource: Sendable {
    func fetchTemplates() async throws -> [Template]
    func addTemplate(_ template: Template) async throws
    func updateTemplate(_ template: Template) async throws
    func deleteTemplate(id: UUID) async throws
    func deleteAllTemplates() async throws
}
