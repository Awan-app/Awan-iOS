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
