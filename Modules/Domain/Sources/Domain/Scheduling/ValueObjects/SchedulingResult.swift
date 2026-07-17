import Foundation

public struct SessionDraft: Hashable, Sendable {
    public let taskID: UUID
    public let zoneID: UUID?
    public let timeRange: TimeRange

    public init(taskID: UUID, zoneID: UUID?, timeRange: TimeRange) {
        self.taskID = taskID
        self.zoneID = zoneID
        self.timeRange = timeRange
    }
}

public enum SchedulingIssueReason: Hashable, Sendable {
    case zoneRequiredForAutomaticScheduling
    case insufficientZoneTime
    case dependencyUnavailable(dependencyIDs: Set<UUID>)
}

public enum ResolutionKind: Hashable, Sendable {
    case splitWithinToday
    case continuePastZone
    case splitAcrossDays
    case scheduleNextAvailableDay
}

public enum ResolutionConsequence: Hashable, Sendable {
    case splitsTask(sessionCount: Int)
    case extendsZone(minutes: Int)
    case usesFutureDay
}

public struct ResolutionCandidate: Hashable, Sendable, Identifiable {
    public struct ID: Hashable, Sendable {
        public let taskID: UUID
        public let kind: ResolutionKind

        public init(taskID: UUID, kind: ResolutionKind) {
            self.taskID = taskID
            self.kind = kind
        }
    }

    public let id: ID
    public let kind: ResolutionKind
    public let sessionDrafts: [SessionDraft]
    public let consequences: [ResolutionConsequence]
    public let requiresUserApproval: Bool

    public init(
        taskID: UUID,
        kind: ResolutionKind,
        sessionDrafts: [SessionDraft],
        consequences: [ResolutionConsequence],
        requiresUserApproval: Bool = true
    ) {
        self.id = ID(taskID: taskID, kind: kind)
        self.kind = kind
        self.sessionDrafts = sessionDrafts
        self.consequences = consequences
        self.requiresUserApproval = requiresUserApproval
    }
}

public struct SchedulingIssue: Hashable, Sendable, Identifiable {
    public var id: UUID { taskID }

    public let taskID: UUID
    public let reason: SchedulingIssueReason
    public let requiredMinutes: Int
    public let availableMinutes: Int
    public let resolutionCandidates: [ResolutionCandidate]

    public init(
        taskID: UUID,
        reason: SchedulingIssueReason,
        requiredMinutes: Int,
        availableMinutes: Int,
        resolutionCandidates: [ResolutionCandidate]
    ) {
        self.taskID = taskID
        self.reason = reason
        self.requiredMinutes = requiredMinutes
        self.availableMinutes = availableMinutes
        self.resolutionCandidates = resolutionCandidates
    }
}

public struct SchedulingResult: Hashable, Sendable {
    public let todaySessionDrafts: [SessionDraft]
    public let issues: [SchedulingIssue]

    public init(todaySessionDrafts: [SessionDraft], issues: [SchedulingIssue]) {
        self.todaySessionDrafts = todaySessionDrafts
        self.issues = issues
    }
}
