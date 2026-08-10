//
//  SessionCompletionResult.swift
//  Domain
//
//  Created by Eslam Elnady on 08/08/2026.
//


public struct SessionCompletionResult: Sendable {
    public let session: Session
    public let reward: CompletionReward

    public init(
        session: Session,
        reward: CompletionReward
    ) {
        self.session = session
        self.reward = reward
    }
}

public struct CompletionReward: Sendable {
    public let points: Points
    public let streak: Streak

    public init(
        points: Points,
        streak: Streak
    ) {
        self.points = points
        self.streak = streak
    }

    public struct Points: Sendable {
        public let awarded: Bool
        public let amount: Int
        public let oldValue: Int
        public let newValue: Int

        public init(
            awarded: Bool,
            amount: Int,
            oldValue: Int,
            newValue: Int
        ) {
            self.awarded = awarded
            self.amount = amount
            self.oldValue = oldValue
            self.newValue = newValue
        }
    }

    public struct Streak: Sendable {
        public let updated: Bool
        public let oldValue: Int
        public let newValue: Int
        public let maxStreakBroken: Bool
        public let maxStreakOld: Int
        public let maxStreakNew: Int

        public init(
            updated: Bool,
            oldValue: Int,
            newValue: Int,
            maxStreakBroken: Bool,
            maxStreakOld: Int,
            maxStreakNew: Int
        ) {
            self.updated = updated
            self.oldValue = oldValue
            self.newValue = newValue
            self.maxStreakBroken = maxStreakBroken
            self.maxStreakOld = maxStreakOld
            self.maxStreakNew = maxStreakNew
        }
    }
}

public typealias SessionCompletionReward = CompletionReward
