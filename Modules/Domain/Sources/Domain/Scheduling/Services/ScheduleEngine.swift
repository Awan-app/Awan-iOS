import Foundation

public protocol ScheduleEngine: Sendable {
    func makePlan(for snapshot: SchedulingSnapshot) throws -> SchedulingResult
}

public struct DefaultScheduleEngine: ScheduleEngine {
    private let dependencyOrdering: any TaskDependencyOrdering
    private let zoneWindowResolver: any ZoneWindowResolving
    private let availabilityCalculator: any AvailabilityCalculating
    private let resolutionCandidateGenerator: any ResolutionCandidateGenerating

    public init(
        dependencyOrdering: any TaskDependencyOrdering = StableTaskDependencySorter(),
        zoneWindowResolver: any ZoneWindowResolving = CalendarZoneWindowResolver(),
        availabilityCalculator: any AvailabilityCalculating = DefaultAvailabilityCalculator(),
        resolutionCandidateGenerator: (any ResolutionCandidateGenerating)? = nil
    ) {
        self.dependencyOrdering = dependencyOrdering
        self.zoneWindowResolver = zoneWindowResolver
        self.availabilityCalculator = availabilityCalculator
        self.resolutionCandidateGenerator = resolutionCandidateGenerator
            ?? DefaultResolutionCandidateGenerator(
                zoneWindowResolver: zoneWindowResolver,
                availabilityCalculator: availabilityCalculator
            )
    }

    public func makePlan(for snapshot: SchedulingSnapshot) throws -> SchedulingResult {
        let zonesByID = Dictionary(uniqueKeysWithValues: snapshot.zones.map { ($0.id, $0) })
        try validateZoneReferences(tasks: snapshot.tasks, zonesByID: zonesByID)

        let orderedTasks = try dependencyOrdering.order(snapshot.tasks)
        let activeSessions = snapshot.sessions.filter(\.occupiesTime)
        let workSessions = snapshot.sessions.filter(\.contributesScheduledWork)
        var occupiedRanges = activeSessions.map(\.timeRange) + snapshot.unavailableTime
        var todayDrafts: [SessionDraft] = []
        var issues: [SchedulingIssue] = []
        var completionByTaskID = existingCompletionTimes(
            tasks: orderedTasks,
            sessions: workSessions
        )

        for task in orderedTasks {
            let existingMinutes = workSessions
                .filter { $0.taskID == task.id }
                .reduce(0) { $0 + $1.timeRange.durationMinutes }
            let remainingMinutes = max(0, task.duration.minutes - existingMinutes)

            guard remainingMinutes > 0 else { continue }

            let unavailableDependencies = Set(
                task.dependencyIDs.filter { completionByTaskID[$0] == nil }
            )
            guard unavailableDependencies.isEmpty else {
                issues.append(
                    SchedulingIssue(
                        taskID: task.id,
                        reason: .dependencyUnavailable(dependencyIDs: unavailableDependencies),
                        requiredMinutes: remainingMinutes,
                        availableMinutes: 0,
                        resolutionCandidates: []
                    )
                )
                continue
            }

            guard let zoneID = task.zoneID else {
                issues.append(
                    SchedulingIssue(
                        taskID: task.id,
                        reason: .zoneRequiredForAutomaticScheduling,
                        requiredMinutes: remainingMinutes,
                        availableMinutes: 0,
                        resolutionCandidates: []
                    )
                )
                continue
            }

            guard let zone = zonesByID[zoneID] else {
                throw SchedulingError.missingZone(taskID: task.id, zoneID: zoneID)
            }

            let earliestAllowedStart = task.dependencyIDs
                .compactMap { completionByTaskID[$0] }
                .max()
            let todayWindow = try zoneWindowResolver.window(
                for: zone,
                on: snapshot.planningDay,
                in: snapshot.timeZone
            )
            let freeRanges = try availabilityCalculator.freeRanges(
                inside: todayWindow,
                excluding: occupiedRanges,
                notBefore: earliestAllowedStart
            )

            if let range = freeRanges.first(where: { $0.durationMinutes >= remainingMinutes }) {
                let end = range.start.addingTimeInterval(TimeInterval(remainingMinutes * 60))
                let draft = SessionDraft(
                    taskID: task.id,
                    zoneID: zoneID,
                    timeRange: try TimeRange(start: range.start, end: end)
                )
                todayDrafts.append(draft)
                occupiedRanges.append(draft.timeRange)
                completionByTaskID[task.id] = latestCompletion(
                    taskID: task.id,
                    sessions: workSessions,
                    drafts: todayDrafts
                )
                continue
            }

            let context = ResolutionContext(
                snapshot: snapshot,
                task: task,
                zone: zone,
                remainingMinutes: remainingMinutes,
                todayWindow: todayWindow,
                todayFreeRanges: freeRanges,
                occupiedRanges: occupiedRanges,
                earliestAllowedStart: earliestAllowedStart
            )
            let candidates = try resolutionCandidateGenerator.candidates(for: context)
            issues.append(
                SchedulingIssue(
                    taskID: task.id,
                    reason: .insufficientZoneTime,
                    requiredMinutes: remainingMinutes,
                    availableMinutes: freeRanges.reduce(0) { $0 + $1.durationMinutes },
                    resolutionCandidates: candidates
                )
            )
        }

        return SchedulingResult(todaySessionDrafts: todayDrafts, issues: issues)
    }

    private func validateZoneReferences(
        tasks: [AwanTask],
        zonesByID: [UUID: Zone]
    ) throws {
        for task in tasks {
            if let zoneID = task.zoneID, zonesByID[zoneID] == nil {
                throw SchedulingError.missingZone(taskID: task.id, zoneID: zoneID)
            }
        }
    }

    private func existingCompletionTimes(
        tasks: [AwanTask],
        sessions: [Session]
    ) -> [UUID: Date] {
        var result: [UUID: Date] = [:]

        for task in tasks {
            let taskSessions = sessions.filter { $0.taskID == task.id }
            let scheduledMinutes = taskSessions.reduce(0) {
                $0 + $1.timeRange.durationMinutes
            }
            if scheduledMinutes >= task.duration.minutes {
                result[task.id] = taskSessions.map(\.timeRange.end).max()
            }
        }

        return result
    }

    private func latestCompletion(
        taskID: UUID,
        sessions: [Session],
        drafts: [SessionDraft]
    ) -> Date? {
        let sessionEnds = sessions
            .filter { $0.taskID == taskID }
            .map(\.timeRange.end)
        let draftEnds = drafts
            .filter { $0.taskID == taskID }
            .map(\.timeRange.end)
        return (sessionEnds + draftEnds).max()
    }
}
