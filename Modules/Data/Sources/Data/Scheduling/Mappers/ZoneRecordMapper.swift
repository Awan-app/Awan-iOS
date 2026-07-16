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
}
