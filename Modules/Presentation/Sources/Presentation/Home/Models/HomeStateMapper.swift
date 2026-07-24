import Common
import Domain
import Foundation

struct HomeStateMapper {
    private let fallbackTimeZone: TimeZone

    init(fallbackTimeZone: TimeZone) {
        self.fallbackTimeZone = fallbackTimeZone
    }

    func map(
        tasks: [AwanTask],
        sessions: [Session],
        zones: [Zone],
        profile: UserProfile,
        selectedDay: Date
    ) -> HomeSuccessState {
        let calendar = calendar(for: profile)
        let window = makeWindow(
            selectedDay: selectedDay,
            preferences: profile.preferences,
            calendar: calendar
        )
        let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        let colorsByZoneID = Dictionary(
            uniqueKeysWithValues: zones.map {
                ($0.id, AppColors.runtime(hex: $0.color.hex))
            }
        )
        let timelineZones = makeTimelineZones(
            zones: zones,
            selectedDay: selectedDay,
            window: window,
            calendar: calendar
        )
        let visibleSessions = sessions
            .filter { $0.status != .cancelled }
            .filter { $0.timeRange.start >= window.start && $0.timeRange.start < window.end }
            .sorted {
                if $0.timeRange.start != $1.timeRange.start {
                    return $0.timeRange.start < $1.timeRange.start
                }
                return $0.id.uuidString < $1.id.uuidString
            }
        let nilGoalUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")
        let displayedSessions = visibleSessions.filter { session in
            guard let task = tasksByID[session.taskID] else { return false }
            guard let goalID = task.goalID, goalID != nilGoalUUID else { return false }
            return true
        }
        let displayedTasks = Set(displayedSessions.map(\.taskID)).compactMap { tasksByID[$0] }
        let taskAllocations = makeTaskAllocations(tasks: displayedTasks, zones: zones)
        let placements = lanePlacements(for: displayedSessions)
        let items = displayedSessions.compactMap { session -> HomeTimelineItem? in
            guard let task = tasksByID[session.taskID] else { return nil }
            let placement = placements[session.id] ?? HomeLanePlacement(lane: 0, laneCount: 1)
            return HomeTimelineItem(
                id: session.id,
                taskID: session.taskID,
                title: task.title,
                points: task.estimatedPoints,
                color: session.zoneID.flatMap { colorsByZoneID[$0] } ?? AppColors.runtimeFallback,
                start: session.timeRange.start,
                end: session.timeRange.end,
                blocking: session.blocking,
                status: session.status,
                lane: placement.lane,
                laneCount: placement.laneCount
            )
        }

        return HomeSuccessState(
            tasks: tasks,
            sessions: sessions,
            zones: zones,
            profile: profile,
            displayName: profile.firstName,
            streakCount: profile.streak,
            rewardPoints: profile.points,
            taskCount: Set(displayedSessions.map(\.taskID)).count,
            scheduledMinutes: displayedSessions.reduce(0) {
                $0 + $1.timeRange.durationMinutes
            },
            completedSessionCount: displayedSessions.filter { $0.status == .completed }.count,
            totalSessionCount: displayedSessions.count,
            taskAllocations: taskAllocations,
            timelineWindow: window,
            timelineZones: timelineZones,
            timelineItems: items
        )
    }

    private func makeTaskAllocations(
        tasks: [AwanTask],
        zones: [Zone]
    ) -> [HomeTaskAllocationItem] {
        let knownZoneIDs = Set(zones.map(\.id))
        var allocations = zones.compactMap { zone -> HomeTaskAllocationItem? in
            let count = tasks.filter { $0.zoneID == zone.id }.count
            guard count > 0 else { return nil }
            return HomeTaskAllocationItem(
                id: .zone(zone.id),
                color: AppColors.runtime(hex: zone.color.hex),
                taskCount: count
            )
        }

        let fallbackCount = tasks.filter { task in
            guard let zoneID = task.zoneID else { return true }
            return !knownZoneIDs.contains(zoneID)
        }.count
        if fallbackCount > 0 {
            allocations.append(
                HomeTaskAllocationItem(
                    id: .fallback,
                    color: AppColors.runtimeFallback,
                    taskCount: fallbackCount
                )
            )
        }
        return allocations
    }

    private func lanePlacements(for sessions: [Session]) -> [UUID: HomeLanePlacement] {
        var groups: [[Session]] = []
        var currentGroup: [Session] = []
        var currentGroupEnd: Date?

        for session in sessions {
            if let groupEnd = currentGroupEnd, session.timeRange.start >= groupEnd {
                groups.append(currentGroup)
                currentGroup = []
                currentGroupEnd = nil
            }

            currentGroup.append(session)
            currentGroupEnd = max(currentGroupEnd ?? session.timeRange.end, session.timeRange.end)
        }
        if !currentGroup.isEmpty { groups.append(currentGroup) }

        var placements: [UUID: HomeLanePlacement] = [:]
        for group in groups {
            var laneEnds: [Date] = []
            var lanesBySessionID: [UUID: Int] = [:]

            for session in group {
                if let lane = laneEnds.firstIndex(where: { $0 <= session.timeRange.start }) {
                    laneEnds[lane] = session.timeRange.end
                    lanesBySessionID[session.id] = lane
                } else {
                    lanesBySessionID[session.id] = laneEnds.count
                    laneEnds.append(session.timeRange.end)
                }
            }

            let laneCount = max(1, laneEnds.count)
            for session in group {
                placements[session.id] = HomeLanePlacement(
                    lane: lanesBySessionID[session.id] ?? 0,
                    laneCount: laneCount
                )
            }
        }
        return placements
    }

    private func makeTimelineZones(
        zones: [Zone],
        selectedDay: Date,
        window: HomeTimelineWindow,
        calendar: Calendar
    ) -> [HomeTimelineZoneItem] {
        let day = calendar.startOfDay(for: selectedDay)

        return zones.compactMap { zone in
            guard let rawStart = calendar.date(
                bySettingHour: zone.startTime.hour,
                minute: zone.startTime.minute,
                second: 0,
                of: day
            ), var rawEnd = calendar.date(
                bySettingHour: zone.endTime.hour,
                minute: zone.endTime.minute,
                second: 0,
                of: day
            ) else {
                return nil
            }

            if zone.endTime <= zone.startTime {
                rawEnd = calendar.date(byAdding: .day, value: 1, to: rawEnd) ?? rawEnd
            }

            let visibleStart = max(rawStart, window.start)
            let visibleEnd = min(rawEnd, window.end)
            guard visibleEnd > visibleStart else { return nil }

            return HomeTimelineZoneItem(
                id: zone.id,
                name: zone.name,
                color: AppColors.runtime(hex: zone.color.hex),
                start: visibleStart,
                end: visibleEnd
            )
        }
        .sorted {
            if $0.start != $1.start { return $0.start < $1.start }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    private func calendar(for profile: UserProfile) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: profile.preferences.timezone) ?? fallbackTimeZone
        return calendar
    }

    private func makeWindow(
        selectedDay: Date,
        preferences: UserPreferences,
        calendar: Calendar
    ) -> HomeTimelineWindow {
        let day = calendar.startOfDay(for: selectedDay)
        let start = calendar.date(
            bySettingHour: preferences.wakeupTime.hour,
            minute: preferences.wakeupTime.minute,
            second: 0,
            of: day
        ) ?? day
        var end = calendar.date(
            bySettingHour: preferences.sleepTime.hour,
            minute: preferences.sleepTime.minute,
            second: 0,
            of: day
        ) ?? day
        if preferences.sleepTime <= preferences.wakeupTime {
            end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }
        return HomeTimelineWindow(start: start, end: end)
    }
}

private struct HomeLanePlacement {
    let lane: Int
    let laneCount: Int
}
