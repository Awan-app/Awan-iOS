import Foundation

public protocol TemplateRepository: Sendable {
    func createWeeklyTemplate(zones: [Zone]) async throws
}
