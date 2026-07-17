import Domain

extension ZoneRecord {
    func toDomain() throws -> Zone {
        try Zone(
            id: id,
            name: name,
            color: ZoneColor(hex: colorHex),
            startTime: LocalTime(hour: startHour, minute: startMinute),
            endTime: LocalTime(hour: endHour, minute: endMinute)
        )
    }

    init(domain zone: Zone) {
        self.init(
            id: zone.id,
            name: zone.name,
            colorHex: zone.color.hex,
            startHour: zone.startTime.hour,
            startMinute: zone.startTime.minute,
            endHour: zone.endTime.hour,
            endMinute: zone.endTime.minute
        )
    }
}
