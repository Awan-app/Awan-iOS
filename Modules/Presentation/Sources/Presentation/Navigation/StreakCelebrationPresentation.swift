//
//  StreakCelebrationPresentation.swift
//  Presentation
//
//  Created by Eslam Elnady on 08/08/2026.
//
import Foundation

public struct StreakCelebrationPresentation: Identifiable, Equatable {
    public let id = UUID()
    public let previousStreak: Int
    public let streak: Int
    public let isNewRecord: Bool

    public init(
        previousStreak: Int,
        streak: Int,
        isNewRecord: Bool
    ) {
        self.previousStreak = previousStreak
        self.streak = streak
        self.isNewRecord = isNewRecord
    }
}
