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
            calendar: calendar
        )
        let timelineWakeupTime = time(
            profile.preferences.wakeupTime,
            on: selectedDay,
            calendar: calendar
        )
        let timelineBedtime = time(
            profile.preferences.sleepTime,
            on: selectedDay,
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
        let displayedSessions = visibleSessions.filter { session in
            tasksByID[session.taskID] != nil
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
                laneCount: placement.laneCount,
                showsCompletionPoints: session.firstCompletedAt == nil
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
            timelineWakeupTime: timelineWakeupTime,
            timelineBedtime: timelineBedtime,
            timelineZones: timelineZones,
            timelineItems: items
        )
    }

    private func makeTaskAllocations(
        tasks: [AwanTask],
        zones: [Zone]
    ) -> [HomeTaskAllocationItem] {
        var emittedCategoryIDs = Set<UUID>()
        let categorizedZones = zones.filter { zone in
            guard let categoryID = zone.category?.id else { return false }
            return emittedCategoryIDs.insert(categoryID).inserted
        }
        let knownCategoryIDs = Set(categorizedZones.compactMap(\.category?.id))
        var allocations = categorizedZones.compactMap { zone -> HomeTaskAllocationItem? in
            guard let categoryID = zone.category?.id else { return nil }
            let count = tasks.filter { $0.category?.id == categoryID }.count
            guard count > 0 else { return nil }
            return HomeTaskAllocationItem(
                id: .category(categoryID),
                color: AppColors.runtime(hex: zone.color.hex),
                taskCount: count
            )
        }

        let fallbackCount = tasks.filter { task in
            guard let categoryID = task.category?.id else { return true }
            return !knownCategoryIDs.contains(categoryID)
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
        calendar: Calendar
    ) -> HomeTimelineWindow {
        let start = calendar.startOfDay(for: selectedDay)
        let end = calendar.date(byAdding: .day, value: 1, to: start)
            ?? start.addingTimeInterval(24 * 60 * 60)
        return HomeTimelineWindow(start: start, end: end)
    }

    private func time(
        _ localTime: LocalTime,
        on selectedDay: Date,
        calendar: Calendar
    ) -> Date {
        let day = calendar.startOfDay(for: selectedDay)
        return calendar.date(
            bySettingHour: localTime.hour,
            minute: localTime.minute,
            second: 0,
            of: day
        ) ?? day
    }
}

private struct HomeLanePlacement {
    let lane: Int
    let laneCount: Int
}
