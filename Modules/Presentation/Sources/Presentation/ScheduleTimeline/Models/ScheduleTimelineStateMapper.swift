import Domain
import Foundation

struct ScheduleTimelineStateMapper {
    private let calendar: Calendar
    private let nudgePresenter: ScheduleNudgePresenter

    init(timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
        self.nudgePresenter = ScheduleNudgePresenter(timeZone: timeZone)
    }

    func mapContent(
        workspace: ScheduleWorkspace,
        selectedDay: Date,
        today: Date
    ) -> ScheduleTimelineContent {
        let timelineItems = makeTimelineItems(
            sessions: workspace.sessions,
            tasks: workspace.tasks,
            zones: workspace.zones,
            selectedDay: selectedDay
        )
        return ScheduleTimelineContent(
            selectedDayTitle: selectedDay.formatted(
                .dateTime.weekday(.wide).month(.wide).day()
            ),
            scheduledMinutes: timelineItems.reduce(0) { $0 + $1.durationMinutes },
            activeGoalProgress: goalProgress(in: workspace),
            weekDays: (0..<7).compactMap {
                calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: today))
            },
            zones: workspace.zones.map {
                TimelineZoneItem(
                    id: $0.id,
                    name: $0.name,
                    colorHex: $0.color.hex,
                    startMinutes: $0.startTime.minutesSinceMidnight,
                    endMinutes: $0.endTime.minutesSinceMidnight
                )
            },
            zoneOptions: workspace.zones.map {
                TimelineZoneOption(id: $0.id, name: $0.name, colorHex: $0.color.hex)
            },
            taskEditorsByID: Dictionary(
                uniqueKeysWithValues: workspace.tasks.map {
                    (
                        $0.id,
                        TimelineTaskEditorModel(
                            id: $0.id,
                            title: $0.title,
                            durationMinutes: $0.duration.minutes,
                            zoneID: $0.zoneID,
                            isSplittable: $0.isSplittable
                        )
                    )
                }
            ),
            timelineItems: timelineItems
        )
    }

    func present(_ nudge: ScheduleNudge) -> TimelineNudgeModel {
        nudgePresenter.present(nudge)
    }

    private func makeTimelineItems(
        sessions: [Session],
        tasks: [AwanTask],
        zones: [Zone],
        selectedDay: Date
    ) -> [TimelineSessionItem] {
        let visibleSessions = sessions
            .filter { calendar.isDate($0.timeRange.start, inSameDayAs: selectedDay) }
            .filter { $0.status != .cancelled }
            .sorted { $0.timeRange.start < $1.timeRange.start }
        var laneEnds: [Date] = []
        var lanesBySessionID: [UUID: Int] = [:]
        for session in visibleSessions {
            if let lane = laneEnds.firstIndex(where: { $0 <= session.timeRange.start }) {
                laneEnds[lane] = session.timeRange.end
                lanesBySessionID[session.id] = lane
            } else {
                lanesBySessionID[session.id] = laneEnds.count
                laneEnds.append(session.timeRange.end)
            }
        }
        let laneCount = max(1, laneEnds.count)

        return visibleSessions.compactMap { session in
            guard let task = tasks.first(where: { $0.id == session.taskID }) else {
                return nil
            }
            let components = calendar.dateComponents(
                [.hour, .minute],
                from: session.timeRange.start
            )
            return TimelineSessionItem(
                id: session.id,
                taskID: task.id,
                title: task.title,
                zoneColorHex: zones
                    .first(where: { $0.id == session.zoneID })?
                    .color.hex ?? "#777777",
                start: session.timeRange.start,
                end: session.timeRange.end,
                startMinutes: ((components.hour ?? 0) * 60) + (components.minute ?? 0),
                durationMinutes: session.timeRange.durationMinutes,
                lane: lanesBySessionID[session.id] ?? 0,
                laneCount: laneCount,
                isUserFixed: session.placement == .userFixed,
                isMissed: session.status == .missed
            )
        }
    }

    private func goalProgress(in workspace: ScheduleWorkspace) -> Double {
        guard let goal = workspace.goals.first else { return 0 }
        let goalTasks = workspace.tasks.filter { $0.goalID == goal.id }
        guard !goalTasks.isEmpty else { return 0 }
        let completed = goalTasks.filter { task in
            workspace.sessions.contains {
                $0.taskID == task.id && $0.status != .missed
            }
        }.count
        return Double(completed) / Double(goalTasks.count)
    }
}

struct ScheduleNudgePresenter {
    private let timeZone: TimeZone

    init(timeZone: TimeZone) {
        self.timeZone = timeZone
    }

    func present(_ nudge: ScheduleNudge) -> TimelineNudgeModel {
        switch nudge {
        case let .overlap(firstSessionID, secondSessionID):
            return TimelineNudgeModel(
                title: "Power combo detected!",
                message: "Two quests share the same time. Keep the combo or give each task its own space.",
                icon: "bolt.heart.fill",
                actions: [
                    action("Keep overlap", "checkmark.circle.fill", "#58CC02", .dismiss),
                    action(
                        "Separate",
                        "arrow.up.and.down",
                        "#1CB0F6",
                        .separateOverlap(
                            OverlappingSessionsRequest(
                            firstSessionID: firstSessionID,
                            secondSessionID: secondSessionID
                            )
                        )
                    ),
                    action(
                        "Move second",
                        "arrow.down.circle.fill",
                        "#A560E8",
                        .moveOverlap(
                            OverlappingSessionsRequest(
                            firstSessionID: firstSessionID,
                            secondSessionID: secondSessionID
                            )
                        )
                    ),
                ]
            )
        case let .schedulingIssue(issue):
            return schedulingIssue(issue)
        case let .missedDependencyChain(goalID, missedTaskID, successorTaskID):
            return TimelineNudgeModel(
                title: "Your quest chain needs help",
                message: "The first step was missed, so the six steps after it are now at risk.",
                icon: "link.badge.plus",
                actions: [
                    action(
                        "Shift the chain",
                        "calendar.badge.clock",
                        "#1CB0F6",
                        .shiftGoalChain(
                            ShiftGoalDependencyChainRequest(
                                goalID: goalID,
                                timeZone: timeZone
                            )
                        )
                    ),
                    action(
                        "Double up",
                        "square.stack.3d.up.fill",
                        "#FF9600",
                        .stackTasks(
                            StackDependentTasksRequest(
                            missedTaskID: missedTaskID,
                            successorTaskID: successorTaskID
                            )
                        )
                    ),
                    action(
                        "Make independent",
                        "link.badge.minus",
                        "#A560E8",
                        .makeTaskIndependent(
                            MakeTaskIndependentRequest(
                                taskID: successorTaskID,
                                dependencyID: missedTaskID
                            )
                        )
                    ),
                    action("Later", "xmark.circle.fill", "#AFAFAF", .dismiss),
                ]
            )
        case let .zoneReconfigured(zoneID, previousZone, affectedSessionIDs):
            return TimelineNudgeModel(
                title: "Work zone changed",
                message: "A session now sits outside the updated zone. Your hand-placed times will always stay sacred.",
                icon: "slider.horizontal.3",
                actions: [
                    action("Keep session", "lock.fill", "#58CC02", .dismiss),
                    action(
                        "Move into zone",
                        "wand.and.stars",
                        "#1CB0F6",
                        .replanZoneSessions(
                            ReplanZoneSessionsRequest(
                            zoneID: zoneID,
                            sessionIDs: affectedSessionIDs,
                            timeZone: timeZone
                            )
                        )
                    ),
                    action(
                        "Undo zone change",
                        "arrow.uturn.backward",
                        "#FF4B4B",
                        .restoreZone(previousZone)
                    ),
                ]
            )
        case let .fixedSessionOverAllocation(
            taskID,
            pendingZoneChange,
            _,
            scheduledMinutes,
            taskMinutes,
            canTrim,
            selectedDay,
            timeZone
        ):
            let excess = scheduledMinutes - taskMinutes
            var actions = [
                action(
                    "Keep extra time",
                    "lock.fill",
                    "#58CC02",
                    .keepFixedOverAllocation(
                        FixedOverAllocationRequest(
                        taskID: taskID,
                        pendingZoneChange: pendingZoneChange,
                        selectedDay: selectedDay,
                        timeZone: timeZone
                        )
                    )
                ),
            ]
            if canTrim {
                actions.append(
                    action(
                        "Trim to task",
                        "scissors",
                        "#FF9600",
                        .trimFixedOverAllocation(
                            FixedOverAllocationRequest(
                            taskID: taskID,
                            pendingZoneChange: pendingZoneChange,
                            selectedDay: selectedDay,
                            timeZone: timeZone
                            )
                        )
                    )
                )
            }
            return TimelineNudgeModel(
                title: "Sacred time is longer",
                message: "Your fixed sessions have \(excess) more minutes than this task now needs.",
                icon: "lock.clock.fill",
                actions: actions
            )
        case let .fixedSessionsOutsideTaskZone(
            taskID,
            previousZoneID,
            zoneID,
            sessionIDs,
            selectedDay,
            timeZone
        ):
            return TimelineNudgeModel(
                title: "Fixed time is outside the zone",
                message: "The new zone is saved, but your hand-placed time has not moved.",
                icon: "lock.rectangle.stack.fill",
                actions: [
                    action(
                        "Keep time",
                        "lock.fill",
                        "#58CC02",
                        .keepFixedSessionsOutsideZone(
                            KeepFixedSessionsOutsideZoneRequest(
                            taskID: taskID,
                            selectedDay: selectedDay,
                            timeZone: timeZone
                            )
                        )
                    ),
                    action(
                        "Move into zone",
                        "wand.and.stars",
                        "#1CB0F6",
                        .moveFixedSessionsIntoZone(
                            MoveFixedSessionsIntoZoneRequest(
                            taskID: taskID,
                            zoneID: zoneID,
                            sessionIDs: sessionIDs,
                            selectedDay: selectedDay,
                            timeZone: timeZone
                            )
                        )
                    ),
                    action(
                        "Undo zone change",
                        "arrow.uturn.backward",
                        "#FF4B4B",
                        .restoreTaskZone(
                            RestoreTaskZoneRequest(
                            taskID: taskID,
                            previousZoneID: previousZoneID,
                            sessionIDs: sessionIDs,
                            selectedDay: selectedDay,
                            timeZone: timeZone
                            )
                        )
                    ),
                ]
            )
        }
    }

    private func schedulingIssue(_ issue: SchedulingIssue) -> TimelineNudgeModel {
        let missing = max(0, issue.requiredMinutes - issue.availableMinutes)
        let actions = issue.resolutionCandidates.map { candidate in
            action(
                title(for: candidate.kind),
                icon(for: candidate.kind),
                color(for: candidate.kind),
                .applyCandidate(candidate)
            )
        } + [action("Leave for now", "clock.badge.exclamationmark", "#AFAFAF", .dismiss)]
        return TimelineNudgeModel(
            title: "This quest needs more room",
            message: "Only \(issue.availableMinutes) minutes fit here. You need \(missing) more minutes.",
            icon: "sparkles",
            actions: actions
        )
    }

    private func action(
        _ title: String,
        _ icon: String,
        _ colorHex: String,
        _ command: ScheduleNudgeCommand
    ) -> TimelineNudgeAction {
        TimelineNudgeAction(
            title: title,
            icon: icon,
            colorHex: colorHex,
            command: command
        )
    }

    private func title(for kind: ResolutionKind) -> String {
        switch kind {
        case .splitWithinToday: "Split today"
        case .continuePastZone: "Finish after zone"
        case .splitAcrossDays: "Split across days"
        case .scheduleNextAvailableDay: "Schedule next day"
        }
    }

    private func icon(for kind: ResolutionKind) -> String {
        switch kind {
        case .splitWithinToday: "rectangle.split.2x1.fill"
        case .continuePastZone: "arrow.right.to.line"
        case .splitAcrossDays: "calendar.badge.plus"
        case .scheduleNextAvailableDay: "sunrise.fill"
        }
    }

    private func color(for kind: ResolutionKind) -> String {
        switch kind {
        case .splitWithinToday: "#58CC02"
        case .continuePastZone: "#FF9600"
        case .splitAcrossDays: "#A560E8"
        case .scheduleNextAvailableDay: "#1CB0F6"
        }
    }
}
