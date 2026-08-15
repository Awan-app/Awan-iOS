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
import Common
import Combine

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
        WakeSleepScheduleValidator.availableHours(wakeupTime: wakeupTime, sleepTime: sleepTime)
    }

    // MARK: - Wake/Sleep validation

    /// `true` when wakeup and sleep represent the same hour and minute.
    public var wakeSleepTimesAreEqual: Bool {
        WakeSleepScheduleValidator.areTimesEqual(wakeupTime: wakeupTime, sleepTime: sleepTime)
    }

    /// `true` when sleep time is earlier in the day than wakeup time.
    public var sleepTimeIsBeforeWakeupTime: Bool {
        WakeSleepScheduleValidator.isSleepTimeBeforeWakeupTime(wakeupTime: wakeupTime, sleepTime: sleepTime)
    }

    /// `true` when wake and sleep times are valid (not equal, and range is positive).
    public var wakeSleepTimeRangeIsValid: Bool {
        WakeSleepScheduleValidator.isTimeRangeValid(wakeupTime: wakeupTime, sleepTime: sleepTime)
    }

    // MARK: - Suggested Zones

    public var suggestedZones: [SuggestedZone]
    public var isAddZoneSheetPresented: Bool = false
    public private(set) var shouldCreateEmptyTemplate = false
    public private(set) var categories: [TaskCategory] = []
    public private(set) var categoryErrorMessage: String?

    public var areZonesCategorized: Bool {
        !categories.isEmpty && suggestedZones.allSatisfy { zone in
            guard let categoryID = zone.category?.id else { return false }
            return categories.contains { $0.id == categoryID }
        }
    }

    public static let defaultSessionDurations = [10, 20, 30, 40, 50, 60, 75, 90, 105, 120, 150, 180]

    // MARK: - Task Length

    public var selectedDuration: Int = 60
    public var customDurationText: String = ""
    
    public var dynamicSessionDurations: [Int] {
        var durations = Self.defaultSessionDurations
        if !durations.contains(selectedDuration) {
            durations.append(selectedDuration)
            durations.sort()
        }
        return durations
    }

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
    private let fetchCategoriesUseCase: any FetchCategoriesUseCase
    @ObservationIgnored let notificationScheduler: NotificationScheduler?
    @ObservationIgnored private var categoryCancellable: AnyCancellable?

    public init(
        completeOnboardingUseCase: any CompleteOnboardingUseCase,
        createOnboardingTemplateUseCase: any CreateOnboardingTemplateUseCase,
        manageZoneScheduleUseCase: any ManageZoneScheduleUseCase,
        fetchCategoriesUseCase: any FetchCategoriesUseCase,
        notificationScheduler: NotificationScheduler? = nil
    ) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.createOnboardingTemplateUseCase = createOnboardingTemplateUseCase
        self.manageZoneScheduleUseCase = manageZoneScheduleUseCase
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.notificationScheduler = notificationScheduler

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
        endTime: String,
        category: TaskCategory
    ) {
        guard let index = suggestedZones.firstIndex(where: { $0.id == id }) else { return }
        suggestedZones[index].name = name
        suggestedZones[index].colorRed = colorRed
        suggestedZones[index].colorGreen = colorGreen
        suggestedZones[index].colorBlue = colorBlue
        suggestedZones[index].startTime = startTime
        suggestedZones[index].endTime = endTime
        suggestedZones[index].category = category
        sortZonesChronologically()
    }

    public func loadCategories() {
        categoryCancellable?.cancel()
        categoryErrorMessage = nil
        categoryCancellable = fetchCategoriesUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    self?.categoryErrorMessage = error.localizedDescription
                },
                receiveValue: { [weak self] categories in
                    self?.applyCategories(categories)
                }
            )
    }

    public func retryCategories() {
        loadCategories()
    }

    public func setZoneSetupForLater() {
        shouldCreateEmptyTemplate = true
    }

    public func useSuggestedZoneSetup() {
        shouldCreateEmptyTemplate = false
    }

    private func applyCategories(_ categories: [TaskCategory]) {
        self.categories = categories
        let general = categories.first {
            $0.name.localizedCaseInsensitiveCompare("General") == .orderedSame
        }
        for index in suggestedZones.indices {
            if let category = suggestedZones[index].category,
               categories.contains(where: { $0.id == category.id }) {
                continue
            }
            suggestedZones[index].category = categories.first {
                $0.name.localizedCaseInsensitiveCompare(suggestedZones[index].name) == .orderedSame
            } ?? general
        }
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

    public var zonesOutsideActiveHours: [SuggestedZone] {
        suggestedZones.filter { zone in
            guard let start = manageZoneScheduleUseCase.parseTime(zone.startTime),
                  let end = manageZoneScheduleUseCase.parseTime(zone.endTime) else { return false }
            return isTimeIntervalOutsideActiveHours(start: start, end: end)
        }
    }

    public var hasZoneOutsideActiveHours: Bool {
        !zonesOutsideActiveHours.isEmpty
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
        guard shouldCreateEmptyTemplate || areZonesCategorized else {
            completionErrorMessage = L10n.Schedule.chooseCategory
            return
        }

        isCompleting = true
        completionErrorMessage = nil
        defer { isCompleting = false }

        if notificationsEnabled {
            let _ = try? await notificationScheduler?.requestAuthorization()
        }

        do {
            let request = try makeDraft().makeRequest()
            _ = try await completeOnboardingUseCase.execute(request)

            let zoneDrafts = shouldCreateEmptyTemplate
                ? []
                : suggestedZones.map(\.asDraft)
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
        let finalDuration = selectedDuration

        return OnboardingDraft(
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            timezone: TimeZone.current.identifier,
            preferredSessionDuration: finalDuration,
            bufferBetweenSessions: 10,
            wakeupTime: wakeupTime,
            sleepTime: sleepTime
        )
    }

    // MARK: - Default zones

    /// Regenerates suggested zones scaled to fit between `wakeupTime` and `sleepTime`.
    /// Called when the user arrives at the Suggested Zones step so they never start out-of-bounds.
    public func resetSuggestedZones() {
        shouldCreateEmptyTemplate = false
        suggestedZones = makeZonesForActiveDay()
    }

    private func makeZonesForActiveDay() -> [SuggestedZone] {
        let calendar = Calendar.current
        let wakeComps = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepComps = calendar.dateComponents([.hour, .minute], from: sleepTime)

        let wakeH = wakeComps.hour ?? 7
        let wakeM = wakeComps.minute ?? 0
        let sleepH = sleepComps.hour ?? 23
        let sleepM = sleepComps.minute ?? 0

        // Express everything in minutes-since-midnight for easy arithmetic.
        let wakeMin = wakeH * 60 + wakeM
        var sleepMin = sleepH * 60 + sleepM
        if sleepMin <= wakeMin { sleepMin += 24 * 60 }   // overnight
        let totalMin = sleepMin - wakeMin

        // Format helper
        func fmt(_ absMin: Int) -> String {
            let m = absMin % (24 * 60)
            let h24 = m / 60
            let mm = m % 60
            let period = h24 < 12 ? "AM" : "PM"
            let h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24)
            return String(format: "%d:%02d %@", h12, mm, period)
        }

        // Usable time without gaps is 870 minutes total in the original template
        // Morning:  120m
        // Work:     480m
        // Personal: 180m
        // Play:      90m
        
        let morningDur = Int(Double(totalMin) * (120.0 / 870.0))
        let workDur = Int(Double(totalMin) * (480.0 / 870.0))
        let personalDur = Int(Double(totalMin) * (180.0 / 870.0))
        // Play gets whatever is left so it aligns perfectly with sleepTime
        
        let morningStart = wakeMin
        let morningEnd = morningStart + morningDur
        
        let workStart = morningEnd
        let workEnd = workStart + workDur
        
        let personalStart = workEnd
        let personalEnd = personalStart + personalDur
        
        let playStart = personalEnd
        let playEnd = sleepMin

        return [
            SuggestedZone(
                id: UUID(),
                name: "Morning",
                startTime: fmt(morningStart),
                endTime: fmt(morningEnd),
                colorRed: 0.3, colorGreen: 0.7, colorBlue: 0.7
            ),
            SuggestedZone(
                id: UUID(),
                name: "Work",
                startTime: fmt(workStart),
                endTime: fmt(workEnd),
                colorRed: 0.3, colorGreen: 0.5, colorBlue: 0.8
            ),
            SuggestedZone(
                id: UUID(),
                name: "Personal",
                startTime: fmt(personalStart),
                endTime: fmt(personalEnd),
                colorRed: 0.9, colorGreen: 0.6, colorBlue: 0.3
            ),
            SuggestedZone(
                id: UUID(),
                name: "Play",
                startTime: fmt(playStart),
                endTime: fmt(playEnd),
                colorRed: 0.85, colorGreen: 0.4, colorBlue: 0.5
            )
        ]
    }

    /// Kept for backward compatibility — still used during init before wake/sleep are set.
    private static func makeDefaultZones() -> [SuggestedZone] {
        [
            SuggestedZone(
                id: UUID(),
                name: "Morning",
                startTime: "7:00 AM",
                endTime: "9:00 AM",
                colorRed: 0.3, colorGreen: 0.7, colorBlue: 0.7
            ),
            SuggestedZone(
                id: UUID(),
                name: "Work",
                startTime: "9:30 AM",
                endTime: "5:30 PM",
                colorRed: 0.3, colorGreen: 0.5, colorBlue: 0.8
            ),
            SuggestedZone(
                id: UUID(),
                name: "Personal",
                startTime: "6:00 PM",
                endTime: "9:00 PM",
                colorRed: 0.9, colorGreen: 0.6, colorBlue: 0.3
            ),
            SuggestedZone(
                id: UUID(),
                name: "Play",
                startTime: "9:30 PM",
                endTime: "11:00 PM",
                colorRed: 0.85, colorGreen: 0.4, colorBlue: 0.5
            )
        ]
    }
}
