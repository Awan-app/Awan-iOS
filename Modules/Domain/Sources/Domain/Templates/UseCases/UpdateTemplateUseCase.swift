import Foundation

public protocol UpdateTemplateUseCase: Sendable {
    func execute(id: UUID, zones: [Zone]) async throws -> Template
}

public struct DefaultUpdateTemplateUseCase: UpdateTemplateUseCase {
    private let repository: any TemplateRepository

    public init(repository: any TemplateRepository) {
        self.repository = repository
    }

    public func execute(id: UUID, zones: [Zone]) async throws -> Template {
        let payload = zones.map {
            ZoneWithoutId(
                name: $0.name,
                color: $0.color,
                startTime: $0.startTime,
                endTime: $0.endTime
            )
        }
        return try await repository.updateTemplate(id: id, zones: payload)
    }
}
