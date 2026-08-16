//
//  InboxPresentationModels.swift
//  Presentation
//

import Domain
import Foundation

public enum InboxTopTab: Hashable, Sendable {
    case inbox
    case goals
}

public enum InboxTaskFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case drafted
    case active
    case completed

    public var id: String { rawValue }
}

public enum InboxSessionFilter: String, CaseIterable, Identifiable, Sendable {
    case any
    case activeNow
    case missed

    public var id: String { rawValue }
}

public typealias InboxSessionDisplayStatus = SessionDisplayStatus

public struct InboxSessionItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let timeRangeText: String
    public let displayStatus: InboxSessionDisplayStatus
    public let underlyingStatus: Session.Status
    public let hasClaimedReward: Bool

    public init(
        id: UUID,
        timeRangeText: String,
        displayStatus: InboxSessionDisplayStatus,
        underlyingStatus: Session.Status,
        hasClaimedReward: Bool = false
    ) {
        self.id = id
        self.timeRangeText = timeRangeText
        self.displayStatus = displayStatus
        self.underlyingStatus = underlyingStatus
        self.hasClaimedReward = hasClaimedReward
    }
}

public struct InboxTaskItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let derivedStatus: InboxTaskStatus
    public let sessionsSummary: String
    public let sessionItems: [InboxSessionItem]
    public let rawTask: AwanTask
    public let availableCompletionPoints: Int
    public let areAllSessionRewardsClaimed: Bool

    public init(
        id: UUID,
        title: String,
        description: String?,
        derivedStatus: InboxTaskStatus,
        sessionsSummary: String,
        sessionItems: [InboxSessionItem],
        rawTask: AwanTask,
        availableCompletionPoints: Int = 0,
        areAllSessionRewardsClaimed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.derivedStatus = derivedStatus
        self.sessionsSummary = sessionsSummary
        self.sessionItems = sessionItems
        self.rawTask = rawTask
        self.availableCompletionPoints = availableCompletionPoints
        self.areAllSessionRewardsClaimed = areAllSessionRewardsClaimed
    }
}
