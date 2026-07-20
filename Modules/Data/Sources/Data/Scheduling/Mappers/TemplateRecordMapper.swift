import Domain
import Foundation

extension TemplateRecord {
    func toDomain() -> Template {
        Template(
            id: id,
            name: name,
            createdAt: createdAt,
            dayOfWeek: dayOfWeek,
            userID: userID
        )
    }

    init(domain template: Template) {
        self.init(
            id: template.id,
            name: template.name,
            createdAt: template.createdAt,
            dayOfWeek: template.dayOfWeek,
            userID: template.userID
        )
    }
}
