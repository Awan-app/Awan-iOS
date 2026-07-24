//
//  File.swift
//  Domain
//
//  Created by Me3bed on 22/07/2026.
//

// Domain package
import Foundation

public protocol ManageZoneScheduleUseCase: Sendable {
    func swapZones(_ zones: [Zone], at sourceIndex: Int, with destinationIndex: Int) -> [Zone]
    func sortedChronologically(_ zones: [Zone]) -> [Zone]
    func isOverlapping(start: String, end: String, in zones: [Zone], excludingID: UUID?) -> Bool
    func isOutsideActiveHours(start: Date, end: Date, wakeupTime: Date, sleepTime: Date) -> Bool
    func firstAvailableInterval(wakeupTime: Date, existingZones: [Zone]) -> (start: Date, end: Date)
    func formatTime(_ date: Date) -> String
    func parseTime(_ timeString: String) -> Date?
}

public final class ManageZoneScheduleUseCaseImpl: ManageZoneScheduleUseCase {

    public init() {}

    // MARK: - Swap

    public func swapZones(_ zones: [Zone], at sourceIndex: Int, with destinationIndex: Int) -> [Zone] {
        guard sourceIndex != destinationIndex,
              zones.indices.contains(sourceIndex),
              zones.indices.contains(destinationIndex) else {
            return zones
        }

        var result = zones
        let firstIdx = min(sourceIndex, destinationIndex)
        let secondIdx = max(sourceIndex, destinationIndex)

        let duration1 = durationInMinutes(start: result[firstIdx].startTime, end: result[firstIdx].endTime)
        let duration2 = durationInMinutes(start: result[secondIdx].startTime, end: result[secondIdx].endTime)

        let initialStartTime = result[firstIdx].startTime

        result.swapAt(firstIdx, secondIdx)

        let newFirstEnd = addMinutes(duration2, to: initialStartTime)
        result[firstIdx] = Zone(
            id: result[firstIdx].id,
            name: result[firstIdx].name,
            color: result[firstIdx].color,
            startTime: initialStartTime,
            endTime: newFirstEnd
        )

        let newSecondEnd = addMinutes(duration1, to: newFirstEnd)
        result[secondIdx] = Zone(
            id: result[secondIdx].id,
            name: result[secondIdx].name,
            color: result[secondIdx].color,
            startTime: newFirstEnd,
            endTime: newSecondEnd
        )

        return result
    }

    // MARK: - Sorting

    public func sortedChronologically(_ zones: [Zone]) -> [Zone] {
        zones.sorted {
            let start1 = $0.startTime.hour * 60 + $0.startTime.minute
            let start2 = $1.startTime.hour * 60 + $1.startTime.minute
            return start1 < start2
        }
    }

    // MARK: - Overlap

    public func isOverlapping(
        start: String,
        end: String,
        in zones: [Zone],
        excludingID: UUID?
    ) -> Bool {
        guard let newStart = minutesSinceMidnight(from: start),
              let newEnd = minutesSinceMidnight(from: end),
              newStart < newEnd else {
            return true
        }

        for zone in zones where zone.id != excludingID {
            let zoneStart = zone.startTime.hour * 60 + zone.startTime.minute
            let zoneEnd = zone.endTime.hour * 60 + zone.endTime.minute
            
            if newStart < zoneEnd && newEnd > zoneStart {
                return true
            }
        }
        return false
    }

    // MARK: - Active hours

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

    // MARK: - First available slot

    public func firstAvailableInterval(wakeupTime: Date, existingZones: [Zone]) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var currentStart = wakeupTime

        for _ in 0..<48 {
            let currentEnd = calendar.date(byAdding: .hour, value: 1, to: currentStart) ?? currentStart

            let startString = formatTime(currentStart)
            let endString = formatTime(currentEnd)

            if !isOverlapping(start: startString, end: endString, in: existingZones, excludingID: nil) {
                return (currentStart, currentEnd)
            }

            currentStart = calendar.date(byAdding: .minute, value: 30, to: currentStart) ?? currentStart
        }

        let fallbackStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
        let fallbackEnd = calendar.date(byAdding: .hour, value: 1, to: fallbackStart) ?? fallbackStart
        return (fallbackStart, fallbackEnd)
    }

    // MARK: - Time formatting

    public func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    public func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timeString)
    }

    // MARK: - Private helpers

    private func minutesSinceMidnight(from timeString: String) -> Int? {
        guard let date = parseTime(timeString) else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return hour * 60 + minute
    }

    private func durationInMinutes(start: LocalTime, end: LocalTime) -> Int {
        let startMins = start.hour * 60 + start.minute
        var endMins = end.hour * 60 + end.minute
        if endMins < startMins {
            endMins += 24 * 60
        }
        return endMins - startMins
    }

    private func addMinutes(_ minutes: Int, to time: LocalTime) -> LocalTime {
        let totalMinutes = time.hour * 60 + time.minute + minutes
        let newHour = (totalMinutes / 60) % 24
        let newMinute = totalMinutes % 60
        return (try? LocalTime(hour: newHour, minute: newMinute)) ?? time
    }
}
