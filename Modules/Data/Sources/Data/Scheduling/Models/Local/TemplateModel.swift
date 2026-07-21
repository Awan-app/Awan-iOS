import Foundation
import SwiftData

@Model
final class TemplateModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var weekDaysRaw: [Int]

    init(id: UUID, name: String, createdAt: Date, weekDaysRaw: [Int]) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.weekDaysRaw = weekDaysRaw
    }
}
