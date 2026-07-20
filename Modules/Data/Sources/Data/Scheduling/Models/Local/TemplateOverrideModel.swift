import Foundation
import SwiftData

@Model
final class TemplateOverrideModel {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var dateKey: String
    var name: String
    var createdAt: Date
    var dateOfDay: Date

    init(
        id: UUID,
        dateKey: String,
        name: String,
        createdAt: Date,
        dateOfDay: Date
    ) {
        self.id = id
        self.dateKey = dateKey
        self.name = name
        self.createdAt = createdAt
        self.dateOfDay = dateOfDay
    }
}
