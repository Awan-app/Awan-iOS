import Foundation

public struct TemplateWeekdayAvailability: Equatable, Sendable {
    public let weekday: TemplateWeekday
    public let occupyingTemplateID: UUID?
    public let occupyingTemplateName: String?

    public var isAvailable: Bool { occupyingTemplateID == nil }
}

public protocol ResolveTemplateWeekdayAvailabilityUseCase: Sendable {
    func execute(
        templates: [Template],
        excludingTemplateID: UUID?
    ) -> [TemplateWeekdayAvailability]
}

public struct DefaultResolveTemplateWeekdayAvailabilityUseCase:
    ResolveTemplateWeekdayAvailabilityUseCase {
    public init() {}

    public func execute(
        templates: [Template],
        excludingTemplateID: UUID?
    ) -> [TemplateWeekdayAvailability] {
        TemplateWeekday.allCases.map { weekday in
            let owner = templates.first {
                $0.id != excludingTemplateID && $0.daysOfWeek.contains(weekday)
            }
            return TemplateWeekdayAvailability(
                weekday: weekday,
                occupyingTemplateID: owner?.id,
                occupyingTemplateName: owner?.name
            )
        }
    }
}
