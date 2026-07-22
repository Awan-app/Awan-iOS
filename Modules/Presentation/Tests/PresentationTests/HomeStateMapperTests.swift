import Common
import Domain
import Foundation
import XCTest
@testable import Presentation

final class HomeStateMapperTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testMapsOvernightWindowAndSummaryFromDisplayedSessions() throws {
        let zone = try makeZone()
        let firstTask = try makeTask(title: "Evening", zoneID: zone.id)
        let secondTask = try makeTask(title: "After midnight", zoneID: zone.id)
        let sessions = [
            try makeSession(taskID: firstTask.id, zoneID: zone.id, day: 22, hour: 22, status: .completed),
            try makeSession(taskID: secondTask.id, zoneID: zone.id, day: 23, hour: 0, minute: 30),
            try makeSession(taskID: secondTask.id, zoneID: zone.id, day: 23, hour: 1),
            try makeSession(taskID: UUID(), zoneID: zone.id, day: 22, hour: 20),
        ]

        let content = HomeStateMapper(fallbackTimeZone: timeZone).map(
            tasks: [firstTask, secondTask],
            sessions: sessions,
            zones: [zone],
            profile: try makeProfile(wakeHour: 8, sleepHour: 1),
            selectedDay: date(day: 22)
        )

        XCTAssertEqual(content.timelineWindow.start, date(day: 22, hour: 8))
        XCTAssertEqual(content.timelineWindow.end, date(day: 23, hour: 1))
        XCTAssertEqual(content.timelineZones.map(\.name), ["Focus"])
        XCTAssertEqual(content.timelineZones.first?.start, date(day: 22, hour: 8))
        XCTAssertEqual(content.timelineZones.first?.end, date(day: 23, hour: 1))
        XCTAssertEqual(content.timelineItems.map(\.title), ["Evening", "After midnight"])
        XCTAssertEqual(content.taskCount, 2)
        XCTAssertEqual(content.scheduledMinutes, 120)
        XCTAssertEqual(content.completedSessionCount, 1)
        XCTAssertEqual(content.totalSessionCount, 2)
    }

    func testUsesFallbackColorWhenSessionZoneIsMissing() throws {
        let task = try makeTask(title: "Unzoned", zoneID: nil)
        let content = HomeStateMapper(fallbackTimeZone: timeZone).map(
            tasks: [task],
            sessions: [try makeSession(taskID: task.id, zoneID: UUID(), day: 22, hour: 10)],
            zones: [],
            profile: try makeProfile(wakeHour: 8, sleepHour: 20),
            selectedDay: date(day: 22)
        )

        XCTAssertEqual(content.timelineItems.first?.color, AppColors.runtimeFallback)
    }

    func testClipsZoneBandsToTheAwakeWindow() throws {
        let earlyZone = try Zone(
            id: UUID(),
            name: "Early",
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 6, minute: 0),
            endTime: LocalTime(hour: 10, minute: 0)
        )
        let lateZone = try Zone(
            id: UUID(),
            name: "Late",
            color: ZoneColor(hex: "#6C63FF"),
            startTime: LocalTime(hour: 18, minute: 0),
            endTime: LocalTime(hour: 23, minute: 0)
        )

        let content = HomeStateMapper(fallbackTimeZone: timeZone).map(
            tasks: [],
            sessions: [],
            zones: [lateZone, earlyZone],
            profile: try makeProfile(wakeHour: 8, sleepHour: 20),
            selectedDay: date(day: 22)
        )

        XCTAssertEqual(content.timelineZones.map(\.name), ["Early", "Late"])
        XCTAssertEqual(content.timelineZones[0].start, date(day: 22, hour: 8))
        XCTAssertEqual(content.timelineZones[0].end, date(day: 22, hour: 10))
        XCTAssertEqual(content.timelineZones[1].start, date(day: 22, hour: 18))
        XCTAssertEqual(content.timelineZones[1].end, date(day: 22, hour: 20))
    }

    func testOverlappingSessionsUseSideBySideLanesAndMapPoints() throws {
        let zone = try makeZone()
        let firstTask = try makeTask(title: "First", zoneID: zone.id, points: 30)
        let secondTask = try makeTask(title: "Second", zoneID: zone.id, points: 45)
        let content = HomeStateMapper(fallbackTimeZone: timeZone).map(
            tasks: [firstTask, secondTask],
            sessions: [
                try makeSession(taskID: firstTask.id, zoneID: zone.id, day: 22, hour: 10),
                try makeSession(
                    taskID: secondTask.id,
                    zoneID: zone.id,
                    day: 22,
                    hour: 10,
                    minute: 30
                ),
            ],
            zones: [zone],
            profile: try makeProfile(wakeHour: 8, sleepHour: 20),
            selectedDay: date(day: 22)
        )

        XCTAssertEqual(content.timelineItems.map(\.laneCount), [2, 2])
        XCTAssertEqual(Set(content.timelineItems.map(\.lane)), [0, 1])
        XCTAssertEqual(content.timelineItems.map(\.points), [30, 45])
        XCTAssertEqual(content.taskAllocations.map(\.taskCount), [2])
    }

    func testTaskAllocationGroupsDistinctVisibleTasksByZone() throws {
        let focusZone = try makeZone()
        let adminZone = try Zone(
            id: UUID(),
            name: "Admin",
            color: ZoneColor(hex: "#6C63FF"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 20, minute: 0)
        )
        let first = try makeTask(title: "First", zoneID: focusZone.id)
        let second = try makeTask(title: "Second", zoneID: focusZone.id)
        let third = try makeTask(title: "Third", zoneID: adminZone.id)

        let content = HomeStateMapper(fallbackTimeZone: timeZone).map(
            tasks: [first, second, third],
            sessions: [
                try makeSession(taskID: first.id, zoneID: focusZone.id, day: 22, hour: 9),
                try makeSession(taskID: second.id, zoneID: focusZone.id, day: 22, hour: 11),
                try makeSession(taskID: third.id, zoneID: adminZone.id, day: 22, hour: 13),
            ],
            zones: [focusZone, adminZone],
            profile: try makeProfile(wakeHour: 8, sleepHour: 20),
            selectedDay: date(day: 22)
        )

        XCTAssertEqual(content.taskAllocations.map(\.taskCount), [2, 1])
    }

    private func makeTask(title: String, zoneID: UUID?, points: Int = 0) throws -> AwanTask {
        try AwanTask(
            id: UUID(),
            title: title,
            zoneID: zoneID,
            duration: TaskDuration(minutes: 60),
            isSplittable: false,
            estimatedPoints: points
        )
    }

    private func makeSession(
        taskID: UUID,
        zoneID: UUID?,
        day: Int,
        hour: Int,
        minute: Int = 0,
        status: Session.Status = .planned
    ) throws -> Session {
        let start = date(day: day, hour: hour, minute: minute)
        return Session(
            id: UUID(),
            taskID: taskID,
            zoneID: zoneID,
            timeRange: try TimeRange(
                start: start,
                end: start.addingTimeInterval(60 * 60)
            ),
            blocking: false,
            status: status
        )
    }

    private func makeZone() throws -> Zone {
        try Zone(
            id: UUID(),
            name: "Focus",
            color: ZoneColor(hex: "#58CC02"),
            startTime: LocalTime(hour: 8, minute: 0),
            endTime: LocalTime(hour: 1, minute: 0)
        )
    }

    private func makeProfile(wakeHour: Int, sleepHour: Int) throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "home@awan.app",
            firstName: "Sam",
            lastName: "Nour",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 100,
            streak: 4,
            maxStreak: 7,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: wakeHour, minute: 0),
                sleepTime: try LocalTime(hour: sleepHour, minute: 0)
            )
        )
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: day,
                hour: hour,
                minute: minute
            )
        ) ?? .distantPast
    }
}
