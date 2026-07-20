import Domain
import Foundation

extension TemplateOverrideRecord {
    func toDomain() -> TemplateOverride {
        TemplateOverride(
            id: id,
            name: name,
            createdAt: createdAt,
            dateOfDay: dateOfDay,
            userID: userID
        )
    }

    init(domain templateOverride: TemplateOverride) {
        self.init(
            id: templateOverride.id,
            name: templateOverride.name,
            createdAt: templateOverride.createdAt,
            dateOfDay: templateOverride.dateOfDay,
            userID: templateOverride.userID
        )
    }
}
