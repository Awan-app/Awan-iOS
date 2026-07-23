//
//  OnboardingViewModel.swift
//  Awan
//
//  Created by Me3bed on 23/07/2026.
//

import Foundation
import Observation
import SwiftUI
import Domain

@Observable
@MainActor
public final class OnboardingViewModel: ZoneManaging {

    // MARK: - Step tracking

    public let totalSteps = 6

    // MARK: - Your Name

    public var firstName: String = ""
    public var lastName: String = ""

    public var isNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    private let createOnboardingTemplateUseCase: any CreateOnboardingTemplateUseCase
    private let manageZoneScheduleUseCase: any ManageZoneScheduleUseCase

    public init(
        completeOnboardingUseCase: any CompleteOnboardingUseCase,
        createOnboardingTemplateUseCase: any CreateOnboardingTemplateUseCase,
        manageZoneScheduleUseCase: any ManageZoneScheduleUseCase
    ) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.createOnboardingTemplateUseCase = createOnboardingTemplateUseCase
        self.manageZoneScheduleUseCase = manageZoneScheduleUseCase

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
    public func moveZone(from source: IndexSet, to destination: Int) {
        let timeSlots = suggestedZones.map { (start: $0.startTime, end: $0.endTime) }

        suggestedZones.move(fromOffsets: source, toOffset: destination)

        for index in suggestedZones.indices {
            suggestedZones[index].startTime = timeSlots[index].start
            suggestedZones[index].endTime = timeSlots[index].end
        }
    }

    /// Swaps two zones directly, preserving their durations and stacking them back-to-back.
    public func swapZones(at sourceIndex: Int, with destinationIndex: Int) {
        let drafts = suggestedZones.map(\.asDraft)
        let updated = manageZoneScheduleUseCase.swapZones(drafts, at: sourceIndex, with: destinationIndex)
        suggestedZones = updated.map(\.asSuggestedZone)
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

    private func sortZonesChronologically() {
        let drafts = suggestedZones.map(\.asDraft)
        let sorted = manageZoneScheduleUseCase.sortedChronologically(drafts)
        suggestedZones = sorted.map(\.asSuggestedZone)
    }

    /// Checks whether a given time interval overlaps any existing zone.
    public func isTimeIntervalOverlapping(
        start: String,
        end: String,
        excludingID: UUID? = nil
    ) -> Bool {
        let drafts = suggestedZones.map(\.asDraft)
        return manageZoneScheduleUseCase.isOverlapping(start: start, end: end, in: drafts, excludingID: excludingID)
    }

    /// Checks whether a given time interval falls outside the user's active hours.
    public func isTimeIntervalOutsideActiveHours(start: Date, end: Date) -> Bool {
        manageZoneScheduleUseCase.isOutsideActiveHours(
            start: start,
            end: end,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    public var hasZoneOutsideActiveHours: Bool {
        suggestedZones.contains { zone in
            guard let start = manageZoneScheduleUseCase.parseTime(zone.startTime),
                  let end = manageZoneScheduleUseCase.parseTime(zone.endTime) else { return false }
            return isTimeIntervalOutsideActiveHours(start: start, end: end)
        }
    }

    /// Returns the first available non-overlapping time interval (duration 1 hour) starting from wakeupTime.
    public func firstAvailableTimeInterval() -> (start: Date, end: Date) {
        let drafts = suggestedZones.map(\.asDraft)
        return manageZoneScheduleUseCase.firstAvailableInterval(wakeupTime: wakeupTime, existingZones: drafts)
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

    // MARK: - Complete / Skip

    public func completeOnboarding() async {
        guard !isCompleting else { return }

        isCompleting = true
        completionErrorMessage = nil
        defer { isCompleting = false }

        do {
            let request = try makeDraft().makeRequest()
            _ = try await completeOnboardingUseCase.execute(request)

            let zoneDrafts = suggestedZones.map(\.asDraft)
            try await createOnboardingTemplateUseCase.execute(zoneDrafts: zoneDrafts)

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
