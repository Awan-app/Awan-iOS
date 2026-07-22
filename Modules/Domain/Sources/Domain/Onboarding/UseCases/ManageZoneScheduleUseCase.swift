//
//  File.swift
//  Domain
//
//  Created by Me3bed on 22/07/2026.
//

// Domain package
import Foundation

public protocol ManageZoneScheduleUseCase: Sendable {
    func swapZones(_ zones: [ZoneDraft], at sourceIndex: Int, with destinationIndex: Int) -> [ZoneDraft]
    func sortedChronologically(_ zones: [ZoneDraft]) -> [ZoneDraft]
    func isOverlapping(start: String, end: String, in zones: [ZoneDraft], excludingID: UUID?) -> Bool
    func isOutsideActiveHours(start: Date, end: Date, wakeupTime: Date, sleepTime: Date) -> Bool
    func firstAvailableInterval(wakeupTime: Date, existingZones: [ZoneDraft]) -> (start: Date, end: Date)
    func formatTime(_ date: Date) -> String
    func parseTime(_ timeString: String) -> Date?
}

public final class ManageZoneScheduleUseCaseImpl: ManageZoneScheduleUseCase {

    public init() {}

    // MARK: - Swap

    public func swapZones(_ zones: [ZoneDraft], at sourceIndex: Int, with destinationIndex: Int) -> [ZoneDraft] {
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
        result[firstIdx] = ZoneDraft(
            id: result[firstIdx].id,
            name: result[firstIdx].name,
            colorRed: result[firstIdx].colorRed,
            colorGreen: result[firstIdx].colorGreen,
            colorBlue: result[firstIdx].colorBlue,
            startTime: initialStartTime,
            endTime: newFirstEnd
        )

        let newSecondEnd = addMinutes(duration1, to: newFirstEnd)
        result[secondIdx] = ZoneDraft(
            id: result[secondIdx].id,
            name: result[secondIdx].name,
            colorRed: result[secondIdx].colorRed,
            colorGreen: result[secondIdx].colorGreen,
            colorBlue: result[secondIdx].colorBlue,
            startTime: newFirstEnd,
            endTime: newSecondEnd
        )

        return result
    }

    // MARK: - Sorting

    public func sortedChronologically(_ zones: [ZoneDraft]) -> [ZoneDraft] {
        zones.sorted {
            let start1 = minutesSinceMidnight(from: $0.startTime) ?? 0
            let start2 = minutesSinceMidnight(from: $1.startTime) ?? 0
            return start1 < start2
        }
    }

    // MARK: - Overlap

    public func isOverlapping(
        start: String,
        end: String,
        in zones: [ZoneDraft],
        excludingID: UUID?
    ) -> Bool {
        guard let newStart = minutesSinceMidnight(from: start),
              let newEnd = minutesSinceMidnight(from: end),
              newStart < newEnd else {
            return true
        }

        for zone in zones where zone.id != excludingID {
            guard let zoneStart = minutesSinceMidnight(from: zone.startTime),
                  let zoneEnd = minutesSinceMidnight(from: zone.endTime) else {
                continue
            }
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

    public func firstAvailableInterval(wakeupTime: Date, existingZones: [ZoneDraft]) -> (start: Date, end: Date) {
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

    private func durationInMinutes(start: String, end: String) -> Int {
        guard let startMins = minutesSinceMidnight(from: start),
              var endMins = minutesSinceMidnight(from: end) else { return 0 }
        if endMins < startMins {
            endMins += 24 * 60
        }
        return endMins - startMins
    }

    private func addMinutes(_ minutes: Int, to timeString: String) -> String {
        guard let date = parseTime(timeString) else { return timeString }
        let newDate = Calendar.current.date(byAdding: .minute, value: minutes, to: date) ?? date
        return formatTime(newDate)
    }
}
