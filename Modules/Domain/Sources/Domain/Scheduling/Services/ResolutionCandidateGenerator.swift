import Foundation

public struct ResolutionContext: Sendable {
    public let snapshot: SchedulingSnapshot
    public let task: AwanTask
    public let zone: Zone
    public let remainingMinutes: Int
    public let todayWindow: TimeRange
    public let todayFreeRanges: [TimeRange]
    public let occupiedRanges: [TimeRange]
    public let earliestAllowedStart: Date?

    public init(
        snapshot: SchedulingSnapshot,
        task: AwanTask,
        zone: Zone,
        remainingMinutes: Int,
        todayWindow: TimeRange,
        todayFreeRanges: [TimeRange],
        occupiedRanges: [TimeRange],
        earliestAllowedStart: Date?
    ) {
        self.snapshot = snapshot
        self.task = task
        self.zone = zone
        self.remainingMinutes = remainingMinutes
        self.todayWindow = todayWindow
        self.todayFreeRanges = todayFreeRanges
        self.occupiedRanges = occupiedRanges
        self.earliestAllowedStart = earliestAllowedStart
    }
}

public protocol ResolutionCandidateGenerating: Sendable {
    func candidates(for context: ResolutionContext) throws -> [ResolutionCandidate]
}

public struct DefaultResolutionCandidateGenerator: ResolutionCandidateGenerating {
    private let zoneWindowResolver: any ZoneWindowResolving
    private let availabilityCalculator: any AvailabilityCalculating

    public init(
        zoneWindowResolver: any ZoneWindowResolving = CalendarZoneWindowResolver(),
        availabilityCalculator: any AvailabilityCalculating = DefaultAvailabilityCalculator()
    ) {
        self.zoneWindowResolver = zoneWindowResolver
        self.availabilityCalculator = availabilityCalculator
    }

    public func candidates(for context: ResolutionContext) throws -> [ResolutionCandidate] {
        var candidates: [ResolutionCandidate] = []

        if context.task.isSplittable,
           let drafts = try splitWithinToday(context),
           drafts.count > 1 {
            candidates.append(
                ResolutionCandidate(
                    taskID: context.task.id,
                    kind: .splitWithinToday,
                    sessionDrafts: drafts,
                    consequences: [.splitsTask(sessionCount: drafts.count)]
                )
            )
        }

        if let candidate = try continuePastZone(context) {
            candidates.append(candidate)
        }

        if context.task.isSplittable,
           let candidate = try splitAcrossDays(context) {
            candidates.append(candidate)
        }

        if let candidate = try scheduleOnNextAvailableDay(context) {
            candidates.append(candidate)
        }

        return candidates
    }

    private func splitWithinToday(_ context: ResolutionContext) throws -> [SessionDraft]? {
        try drafts(
            task: context.task,
            zoneID: context.zone.id,
            minutes: context.remainingMinutes,
            freeRanges: context.todayFreeRanges,
            minimumSessionMinutes: context.snapshot.configuration.minimumSessionMinutes
        )
    }

    private func continuePastZone(_ context: ResolutionContext) throws -> ResolutionCandidate? {
        let duration = TimeInterval(context.remainingMinutes * 60)
        let options = try context.todayFreeRanges.compactMap { freeRange -> SessionDraft? in
            let end = freeRange.start.addingTimeInterval(duration)
            guard end > context.todayWindow.end else { return nil }

            let proposedRange = try TimeRange(start: freeRange.start, end: end)
            guard !context.occupiedRanges.contains(where: proposedRange.overlaps) else {
                return nil
            }

            return SessionDraft(
                taskID: context.task.id,
                zoneID: context.zone.id,
                timeRange: proposedRange
            )
        }

        guard let draft = options.min(by: {
            let lhsExtension = $0.timeRange.end.timeIntervalSince(context.todayWindow.end)
            let rhsExtension = $1.timeRange.end.timeIntervalSince(context.todayWindow.end)
            return lhsExtension == rhsExtension
                ? $0.timeRange.start < $1.timeRange.start
                : lhsExtension < rhsExtension
        }) else {
            return nil
        }

        let extensionMinutes = Int(draft.timeRange.end.timeIntervalSince(context.todayWindow.end) / 60)
        return ResolutionCandidate(
            taskID: context.task.id,
            kind: .continuePastZone,
            sessionDrafts: [draft],
            consequences: [.extendsZone(minutes: extensionMinutes)]
        )
    }

    private func splitAcrossDays(_ context: ResolutionContext) throws -> ResolutionCandidate? {
        let minimum = context.snapshot.configuration.minimumSessionMinutes

        for todayRange in context.todayFreeRanges where todayRange.durationMinutes >= minimum {
            let todayMinutes = min(todayRange.durationMinutes, context.remainingMinutes - minimum)
            guard todayMinutes >= minimum else { continue }

            let remaining = context.remainingMinutes - todayMinutes
            guard let futureDraft = try firstFutureDraft(
                context: context,
                requiredMinutes: remaining
            ) else {
                continue
            }

            let todayEnd = todayRange.start.addingTimeInterval(TimeInterval(todayMinutes * 60))
            let todayDraft = SessionDraft(
                taskID: context.task.id,
                zoneID: context.zone.id,
                timeRange: try TimeRange(start: todayRange.start, end: todayEnd)
            )
            let drafts = [todayDraft, futureDraft]

            return ResolutionCandidate(
                taskID: context.task.id,
                kind: .splitAcrossDays,
                sessionDrafts: drafts,
                consequences: [
                    .splitsTask(sessionCount: drafts.count),
                    .usesFutureDay,
                ]
            )
        }

        return nil
    }

    private func scheduleOnNextAvailableDay(
        _ context: ResolutionContext
    ) throws -> ResolutionCandidate? {
        guard let draft = try firstFutureDraft(
            context: context,
            requiredMinutes: context.remainingMinutes
        ) else {
            return nil
        }

        return ResolutionCandidate(
            taskID: context.task.id,
            kind: .scheduleNextAvailableDay,
            sessionDrafts: [draft],
            consequences: [.usesFutureDay]
        )
    }

    private func firstFutureDraft(
        context: ResolutionContext,
        requiredMinutes: Int
    ) throws -> SessionDraft? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = context.snapshot.timeZone

        for dayOffset in 1...context.snapshot.configuration.futureSearchDayLimit {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: context.snapshot.planningDay
            ) else {
                continue
            }

            let window = try zoneWindowResolver.window(
                for: context.zone,
                on: day,
                in: context.snapshot.timeZone
            )
            let freeRanges = try availabilityCalculator.freeRanges(
                inside: window,
                excluding: context.occupiedRanges,
                notBefore: context.earliestAllowedStart
            )

            guard let freeRange = freeRanges.first(where: {
                $0.durationMinutes >= requiredMinutes
            }) else {
                continue
            }

            let end = freeRange.start.addingTimeInterval(TimeInterval(requiredMinutes * 60))
            return SessionDraft(
                taskID: context.task.id,
                zoneID: context.zone.id,
                timeRange: try TimeRange(start: freeRange.start, end: end)
            )
        }

        return nil
    }

    private func drafts(
        task: AwanTask,
        zoneID: UUID,
        minutes: Int,
        freeRanges: [TimeRange],
        minimumSessionMinutes: Int
    ) throws -> [SessionDraft]? {
        var remaining = minutes
        var result: [SessionDraft] = []

        for range in freeRanges where remaining > 0 {
            if remaining <= range.durationMinutes {
                guard remaining >= minimumSessionMinutes else { return nil }
                let end = range.start.addingTimeInterval(TimeInterval(remaining * 60))
                result.append(
                    SessionDraft(
                        taskID: task.id,
                        zoneID: zoneID,
                        timeRange: try TimeRange(start: range.start, end: end)
                    )
                )
                remaining = 0
                break
            }

            let maximumWithoutShortRemainder = remaining - minimumSessionMinutes
            let allocated = min(range.durationMinutes, maximumWithoutShortRemainder)
            guard allocated >= minimumSessionMinutes else { continue }

            let end = range.start.addingTimeInterval(TimeInterval(allocated * 60))
            result.append(
                SessionDraft(
                    taskID: task.id,
                    zoneID: zoneID,
                    timeRange: try TimeRange(start: range.start, end: end)
                )
            )
            remaining -= allocated
        }

        return remaining == 0 ? result : nil
    }
}
