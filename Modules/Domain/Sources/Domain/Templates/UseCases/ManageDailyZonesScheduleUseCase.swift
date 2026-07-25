import Foundation

public protocol ManageDailyZoneScheduleUseCase: Sendable {
    func sortedChronologically(_ zones: [Zone]) -> [Zone]
    func swapZones(_ zones: [Zone], at sourceIndex: Int, with destinationIndex: Int) -> [Zone]
    func firstAvailableInterval(wakeupTime: Date, existingZones: [Zone]) -> (start: Date, end: Date)
    func isOverlapping(start: String, end: String, in zones: [Zone], excludingID: UUID?) -> Bool
    func isOutsideActiveHours(start: Date, end: Date, wakeupTime: Date, sleepTime: Date) -> Bool
    func defaultTemplate(from templates: [Template]) -> Template?
    func zones(forTemplate template: Template) -> [Zone]
    func hasZoneOutsideActiveHours(_ zones: [Zone], wakeupTime: Date, sleepTime: Date) -> Bool
    func addingZone(_ zone: Zone, to zones: [Zone]) -> [Zone]
    func updatingZone(_ zone: Zone, in zones: [Zone]) -> [Zone]
    func movingZones(from source: IndexSet, to destination: Int, in zones: [Zone]) -> [Zone]
    func availableHours(wakeupTime: Date, sleepTime: Date) -> Int
}

public struct DefaultManageDailyZoneScheduleUseCase: ManageDailyZoneScheduleUseCase {
    public init() {}

    public func sortedChronologically(_ zones: [Zone]) -> [Zone] {
        zones.sorted {
            $0.startTime.minutesSinceMidnight < $1.startTime.minutesSinceMidnight
        }
    }

    public func swapZones(_ zones: [Zone], at sourceIndex: Int, with destinationIndex: Int) -> [Zone] {
        guard sourceIndex != destinationIndex, zones.indices.contains(sourceIndex), zones.indices.contains(destinationIndex) else {
            return zones
        }
        var updated = zones
        let timeSlots = zones.map { (start: $0.startTime, end: $0.endTime) }
        updated.swapAt(sourceIndex, destinationIndex)

        updated[sourceIndex] = Zone(id: updated[sourceIndex].id, name: updated[sourceIndex].name, color: updated[sourceIndex].color, startTime: timeSlots[sourceIndex].start, endTime: timeSlots[sourceIndex].end)
        updated[destinationIndex] = Zone(id: updated[destinationIndex].id, name: updated[destinationIndex].name, color: updated[destinationIndex].color, startTime: timeSlots[destinationIndex].start, endTime: timeSlots[destinationIndex].end)
        return updated
    }

    public func firstAvailableInterval(wakeupTime: Date, existingZones: [Zone]) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var currentStart = wakeupTime

        for _ in 0..<48 {
            let currentEnd = calendar.date(byAdding: .hour, value: 1, to: currentStart) ?? currentStart

            if !isOverlapping(
                start: formatTime(currentStart),
                end: formatTime(currentEnd),
                in: existingZones,
                excludingID: nil
            ) {
                return (currentStart, currentEnd)
            }
            currentStart = calendar.date(byAdding: .minute, value: 30, to: currentStart) ?? currentStart
        }
        let fallbackStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
        let fallbackEnd = calendar.date(byAdding: .hour, value: 1, to: fallbackStart) ?? fallbackStart
        return (fallbackStart, fallbackEnd)
    }

    public func isOverlapping(start: String, end: String, in zones: [Zone], excludingID: UUID?) -> Bool {
        guard let newStart = minutesSinceMidnight(from: start),
              let newEnd = minutesSinceMidnight(from: end),
              newStart < newEnd else {
            return true
        }

        for zone in zones where zone.id != excludingID {
            let zoneStart = zone.startTime.minutesSinceMidnight
            let zoneEnd = zone.endTime.minutesSinceMidnight
            if newStart < zoneEnd && newEnd > zoneStart {
                return true
            }
        }
        return false
    }

    public func isOutsideActiveHours(start: Date, end: Date, wakeupTime: Date, sleepTime: Date) -> Bool {
        let calendar = Calendar.current
        let wakeMins = calendar.component(.hour, from: wakeupTime) * 60 + calendar.component(.minute, from: wakeupTime)
        var sleepMins = calendar.component(.hour, from: sleepTime) * 60 + calendar.component(.minute, from: sleepTime)
        if sleepMins <= wakeMins {
            sleepMins += 24 * 60
        }

        let startMinsRaw = calendar.component(.hour, from: start) * 60 + calendar.component(.minute, from: start)
        let endMinsRaw = calendar.component(.hour, from: end) * 60 + calendar.component(.minute, from: end)

        var startMins = startMinsRaw
        if startMins < wakeMins { startMins += 24 * 60 }

        var endMins = endMinsRaw
        if endMins <= startMins { endMins += 24 * 60 }

        return startMins < wakeMins || endMins > sleepMins || startMins > sleepMins
    }

    public func zones(forTemplate template: Template) -> [Zone] {
        return sortedChronologically(template.zones)
    }

    public func defaultTemplate(from templates: [Template]) -> Template? {
        templates.min {
            firstDayValue(in: $0) < firstDayValue(in: $1)
        }
    }

    public func hasZoneOutsideActiveHours(_ zones: [Zone], wakeupTime: Date, sleepTime: Date) -> Bool {
        zones.contains { zone in
            isOutsideActiveHours(
                start: date(from: zone.startTime),
                end: date(from: zone.endTime),
                wakeupTime: wakeupTime,
                sleepTime: sleepTime
            )
        }
    }

    public func addingZone(_ zone: Zone, to zones: [Zone]) -> [Zone] {
        var updated = zones
        updated.append(zone)
        return sortedChronologically(updated)
    }

    public func updatingZone(_ zone: Zone, in zones: [Zone]) -> [Zone] {
        var updated = zones
        guard let index = updated.firstIndex(where: { $0.id == zone.id }) else { return zones }
        updated[index] = zone
        return sortedChronologically(updated)
    }

    public func movingZones(from source: IndexSet, to destination: Int, in zones: [Zone]) -> [Zone] {
        var updated = zones
        let timeSlots = updated.map { (start: $0.startTime, end: $0.endTime) }

        let elements = source.map { updated[$0] }
        for index in source.sorted(by: >) {
            updated.remove(at: index)
        }

        var adjustedDestination = destination
        for index in source {
            if index < destination {
                adjustedDestination -= 1
            }
        }
        updated.insert(contentsOf: elements, at: adjustedDestination)

        for index in updated.indices {
            updated[index] = Zone(id: updated[index].id, name: updated[index].name, color: updated[index].color, startTime: timeSlots[index].start, endTime: timeSlots[index].end)
        }
        return updated
    }

    public func availableHours(wakeupTime: Date, sleepTime: Date) -> Int {
        let calendar = Calendar.current
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)

        let wakeMinutes = (wakeComponents.hour ?? 7) * 60 + (wakeComponents.minute ?? 0)
        var sleepMinutes = (sleepComponents.hour ?? 23) * 60 + (sleepComponents.minute ?? 0)

        if sleepMinutes <= wakeMinutes {
            sleepMinutes += 24 * 60
        }

        return (sleepMinutes - wakeMinutes) / 60
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timeString)
    }

    private func minutesSinceMidnight(from timeString: String) -> Int? {
        guard let date = parseTime(timeString) else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return hour * 60 + minute
    }

    private func date(from time: LocalTime) -> Date {
        Calendar.current.date(
            from: DateComponents(hour: time.hour, minute: time.minute)
        ) ?? .now
    }

    private func firstDayValue(in template: Template) -> Int {
        template.daysOfWeek.map(dayValue).min() ?? 7
    }

    private func dayValue(_ day: String) -> Int {
        switch day.uppercased() {
        case "MONDAY": return 0
        case "TUESDAY": return 1
        case "WEDNESDAY": return 2
        case "THURSDAY": return 3
        case "FRIDAY": return 4
        case "SATURDAY": return 5
        case "SUNDAY": return 6
        default: return 7
        }
    }
}
