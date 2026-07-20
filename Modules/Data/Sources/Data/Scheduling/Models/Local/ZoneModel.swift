import Foundation
import SwiftData

@Model
final class ZoneModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var templateID: UUID?
    var templateOverrideID: UUID?

    init(
        id: UUID,
        name: String,
        colorHex: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        templateID: UUID?,
        templateOverrideID: UUID?
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.templateID = templateID
        self.templateOverrideID = templateOverrideID
    }
}
