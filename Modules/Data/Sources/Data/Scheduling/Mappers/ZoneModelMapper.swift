import Domain
import Foundation

extension ZoneModel {
    func toDomain() throws -> Zone {
        try Zone(
            id: id,
            name: name,
            color: ZoneColor(hex: colorHex),
            startTime: LocalTime(hour: startHour, minute: startMinute),
            endTime: LocalTime(hour: endHour, minute: endMinute)
        )
    }

    convenience init(domain zone: Zone, templateID: UUID?, templateOverrideID: UUID?) {
        self.init(
            id: zone.id,
            name: zone.name,
            colorHex: zone.color.hex,
            startHour: zone.startTime.hour,
            startMinute: zone.startTime.minute,
            endHour: zone.endTime.hour,
            endMinute: zone.endTime.minute,
            templateID: templateID,
            templateOverrideID: templateOverrideID
        )
    }

    func update(from zone: Zone) {
        name = zone.name
        colorHex = zone.color.hex
        startHour = zone.startTime.hour
        startMinute = zone.startTime.minute
        endHour = zone.endTime.hour
        endMinute = zone.endTime.minute
    }

    var hasValidOwner: Bool {
        (templateID != nil) != (templateOverrideID != nil)
    }
}
