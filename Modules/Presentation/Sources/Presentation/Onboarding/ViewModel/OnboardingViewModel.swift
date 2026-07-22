//
//  OnboardingViewModel.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Foundation
import Observation
import SwiftUI
import Domain

@Observable
@MainActor
public final class OnboardingViewModel {

    // MARK: - Step tracking

    public let totalSteps = 6

    // MARK: - Your Name

    public var firstName: String = ""
    public var lastName: String = ""

    public var isNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var greetingPreview: String {
        let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Good morning" : "Good morning, \(name)"
    }

    // MARK: - Wake & Sleep

    public var wakeupTime: Date
    public var sleepTime: Date

    public var availableHours: Int {
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

    // MARK: - Suggested Zones

    public var suggestedZones: [SuggestedZone]
    public var isAddZoneSheetPresented: Bool = false

    // MARK: - Task Length

    public var focusDurationIndex: Int = 2

    // MARK: - Task Simulation

    public var addedTasks: [TaskItem] = []
    public var taskText: String = ""

    // MARK: - Notification

    public var notificationsEnabled: Bool = false

    // MARK: - Completion

    public private(set) var isCompleting: Bool = false
    public private(set) var completionErrorMessage: String?

    // MARK: - Callbacks

    public var onComplete: (() -> Void)?
    public var onSkip: (() -> Void)?

    // MARK: - Init

    private let completeOnboardingUseCase: any CompleteOnboardingUseCase

    public init(completeOnboardingUseCase: any CompleteOnboardingUseCase) {
        self.completeOnboardingUseCase = completeOnboardingUseCase

        let calendar = Calendar.current
        self.wakeupTime = calendar.date(
            from: DateComponents(hour: 7, minute: 0)
        ) ?? .now
        self.sleepTime = calendar.date(
            from: DateComponents(hour: 23, minute: 0)
        ) ?? .now

        self.suggestedZones = Self.makeDefaultZones()
    }

    // MARK: - Zone actions

    public func removeZone(_ zone: SuggestedZone) {
        suggestedZones.removeAll { $0.id == zone.id }
    }

    /// Reorders zones while keeping time intervals tied to their positional slots.
    /// When the user drags Zone A to Zone B's position, Zone A gets Zone B's
    /// original time slot and vice versa.
    public func moveZone(from source: IndexSet, to destination: Int) {
        // Capture the positional time slots before the move
        let timeSlots = suggestedZones.map { (start: $0.startTime, end: $0.endTime) }

        // Perform the standard array move
        suggestedZones.move(fromOffsets: source, toOffset: destination)

        // Reassign the original positional time slots
        for index in suggestedZones.indices {
            suggestedZones[index].startTime = timeSlots[index].start
            suggestedZones[index].endTime = timeSlots[index].end
        }
    }

    /// Swaps two zones directly, preserving their durations and stacking them back-to-back.
    public func swapZones(at sourceIndex: Int, with destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              suggestedZones.indices.contains(sourceIndex),
              suggestedZones.indices.contains(destinationIndex) else {
            return
        }
        
        let firstIdx = min(sourceIndex, destinationIndex)
        let secondIdx = max(sourceIndex, destinationIndex)
        
        let duration1 = durationInMinutes(start: suggestedZones[firstIdx].startTime, end: suggestedZones[firstIdx].endTime)
        let duration2 = durationInMinutes(start: suggestedZones[secondIdx].startTime, end: suggestedZones[secondIdx].endTime)
        
        let initialStartTime = suggestedZones[firstIdx].startTime
        
        suggestedZones.swapAt(firstIdx, secondIdx)
        
        let newFirstEnd = addMinutes(duration2, to: initialStartTime)
        suggestedZones[firstIdx].startTime = initialStartTime
        suggestedZones[firstIdx].endTime = newFirstEnd
        
        let newSecondEnd = addMinutes(duration1, to: newFirstEnd)
        suggestedZones[secondIdx].startTime = newFirstEnd
        suggestedZones[secondIdx].endTime = newSecondEnd
    }

    private func durationInMinutes(start: String, end: String) -> Int {
        guard let startMins = Self.minutesSinceMidnight(from: start),
              var endMins = Self.minutesSinceMidnight(from: end) else { return 0 }
        if endMins < startMins {
            endMins += 24 * 60
        }
        return endMins - startMins
    }

    private func addMinutes(_ minutes: Int, to timeString: String) -> String {
        guard let date = Self.parseTime(timeString) else { return timeString }
        let newDate = Calendar.current.date(byAdding: .minute, value: minutes, to: date) ?? date
        return Self.formatTime(newDate)
    }

    /// Adds a new zone to the list and sorts it chronologically.
    public func addZone(_ zone: SuggestedZone) {
        suggestedZones.append(zone)
        sortZonesChronologically()
    }

    /// Updates the properties of an existing zone.
    public func updateZone(
        id: UUID,
        name: String,
        colorRed: Double,
        colorGreen: Double,
        colorBlue: Double,
        startTime: String,
        endTime: String
    ) {
        guard let index = suggestedZones.firstIndex(where: { $0.id == id }) else { return }
        suggestedZones[index].name = name
        suggestedZones[index].colorRed = colorRed
        suggestedZones[index].colorGreen = colorGreen
        suggestedZones[index].colorBlue = colorBlue
        suggestedZones[index].startTime = startTime
        suggestedZones[index].endTime = endTime
        sortZonesChronologically()
    }

    /// Sorts zones based on their start time.
    private func sortZonesChronologically() {
        suggestedZones.sort {
            let start1 = Self.minutesSinceMidnight(from: $0.startTime) ?? 0
            let start2 = Self.minutesSinceMidnight(from: $1.startTime) ?? 0
            return start1 < start2
        }
    }

    /// Checks whether a given time interval overlaps any existing zone.
    /// - Parameters:
    ///   - start: Start time string in `h:mm a` format.
    ///   - end: End time string in `h:mm a` format.
    ///   - excludingID: Optional zone ID to exclude (useful for editing).
    /// - Returns: `true` if the interval overlaps an existing zone.
    public func isTimeIntervalOverlapping(
        start: String,
        end: String,
        excludingID: UUID? = nil
    ) -> Bool {
        guard let newStart = Self.minutesSinceMidnight(from: start),
              let newEnd = Self.minutesSinceMidnight(from: end),
              newStart < newEnd else {
            return true // Invalid interval counts as overlapping
        }

        for zone in suggestedZones where zone.id != excludingID {
            guard let zoneStart = Self.minutesSinceMidnight(from: zone.startTime),
                  let zoneEnd = Self.minutesSinceMidnight(from: zone.endTime) else {
                continue
            }
            // Two intervals overlap if one starts before the other ends
            if newStart < zoneEnd && newEnd > zoneStart {
                return true
            }
        }
        return false
    }

    /// Checks whether a given time interval falls outside the user's active hours (wakeupTime to sleepTime).
    public func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool {
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

    public var hasZoneOutsideActiveHours: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return suggestedZones.contains { zone in
            guard let start = formatter.date(from: zone.startTime),
                  let end = formatter.date(from: zone.endTime) else { return false }
            return isTimeIntervalOutsideActiveHours(start: start, end: end)
        }
    }

    /// Returns the first available non-overlapping time interval (duration 1 hour) starting from wakeupTime.
    public func firstAvailableTimeInterval() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var currentStart = wakeupTime
        
        // Cap the search to 24 hours to prevent infinite loop (48 * 30 mins)
        for _ in 0..<48 {
            let currentEnd = calendar.date(byAdding: .hour, value: 1, to: currentStart) ?? currentStart
            
            let startString = Self.formatTime(currentStart)
            let endString = Self.formatTime(currentEnd)
            
            if !isTimeIntervalOverlapping(start: startString, end: endString) {
                return (currentStart, currentEnd)
            }
            
            // Advance by 30 minutes
            currentStart = calendar.date(byAdding: .minute, value: 30, to: currentStart) ?? currentStart
        }
        
        // Fallback: 8 AM to 9 AM
        let fallbackStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
        let fallbackEnd = calendar.date(byAdding: .hour, value: 1, to: fallbackStart) ?? fallbackStart
        return (fallbackStart, fallbackEnd)
    }

    /// Formats a `Date` into a display string like `"7:00 AM"`.
    public static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    /// Parses a time string like `"7:00 AM"` into a `Date`.
    public static func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timeString)
    }

    /// Parses a time string like `"7:00 AM"` into minutes since midnight.
    private static func minutesSinceMidnight(from timeString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: timeString) else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return hour * 60 + minute
    }

    // MARK: - Complete / Skip

    public func completeOnboarding() async {
        guard !isCompleting else { return }

        isCompleting = true
        completionErrorMessage = nil
        defer { isCompleting = false }

        do {
            let request = try makeDraft().makeRequest()
            _ = try await completeOnboardingUseCase.execute(request)
            onComplete?()
        } catch is CancellationError {
            return
        } catch {
            completionErrorMessage = error.localizedDescription
        }
    }

    public func skipOnboarding() {
        onSkip?()
    }

    public func dismissCompletionError() {
        completionErrorMessage = nil
    }

    private func makeDraft(calendar: Calendar = .current) -> OnboardingDraft {
        let birthDate = calendar.date(
            from: DateComponents(year: 2000, month: 1, day: 1)
        ) ?? Date(timeIntervalSince1970: 946_684_800)
        let sessionDurations = [30, 45, 60, 90, 120, 180]
        let durationIndex = min(max(focusDurationIndex, 0), sessionDurations.count - 1)

        return OnboardingDraft(
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            timezone: TimeZone.current.identifier,
            preferredSessionDuration: sessionDurations[durationIndex],
            bufferBetweenSessions: 10,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    // MARK: - Default zones

    private static func makeDefaultZones() -> [SuggestedZone] {
        [
            SuggestedZone(
                id: UUID(),
                name: "Study",
                startTime: "7:00 AM",
                endTime: "9:30 AM",
                colorRed: 0.3, colorGreen: 0.7, colorBlue: 0.7
            ),
            SuggestedZone(
                id: UUID(),
                name: "Work",
                startTime: "9:30 AM",
                endTime: "1:00 PM",
                colorRed: 0.3, colorGreen: 0.5, colorBlue: 0.8
            ),
            SuggestedZone(
                id: UUID(),
                name: "Personal",
                startTime: "1:00 PM",
                endTime: "6:00 PM",
                colorRed: 0.9, colorGreen: 0.6, colorBlue: 0.3
            ),
            SuggestedZone(
                id: UUID(),
                name: "Play",
                startTime: "6:00 PM",
                endTime: "11:00 PM",
                colorRed: 0.85, colorGreen: 0.4, colorBlue: 0.5
            )
        ]
    }
}
