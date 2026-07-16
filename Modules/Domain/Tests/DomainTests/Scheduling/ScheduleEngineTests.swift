import Foundation
import XCTest
@testable import Domain

final class ScheduleEngineTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testEngineSchedulesAfterUserFixedSessionWithoutMovingIt() throws {
        let zone = try makeZone(startHour: 9, endHour: 17)
        let fixedTask = try makeTask(id: uuid(1), zoneID: zone.id, minutes: 60)
        let taskToSchedule = try makeTask(id: uuid(2), zoneID: zone.id, minutes: 60)
        let fixedRange = try TimeRange(
            start: date(day: 17, hour: 9),
            end: date(day: 17, hour: 10)
        )
        let fixedSession = Session(
            id: uuid(20),
            taskID: fixedTask.id,
            zoneID: zone.id,
            timeRange: fixedRange,
            placement: .userFixed,
            status: .planned
        )
        let snapshot = SchedulingSnapshot(
            planningDay: date(day: 17),
            timeZone: timeZone,
            zones: [zone],
            goals: [],
            tasks: [fixedTask, taskToSchedule],
            sessions: [fixedSession]
        )

        let result = try DefaultScheduleEngine().makePlan(for: snapshot)

        XCTAssertEqual(result.todaySessionDrafts.count, 1)
        XCTAssertEqual(result.todaySessionDrafts.first?.taskID, taskToSchedule.id)
        XCTAssertEqual(result.todaySessionDrafts.first?.timeRange.start, date(day: 17, hour: 10))
        XCTAssertEqual(fixedSession.timeRange, fixedRange)
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testEngineReturnsApprovalCandidatesInsteadOfSchedulingTomorrowSilently() throws {
        let zone = try makeZone(startHour: 9, endHour: 17)
        let occupyingTask = try makeTask(id: uuid(1), zoneID: zone.id, minutes: 450)
        let overflowTask = try makeTask(
            id: uuid(2),
            zoneID: zone.id,
            minutes: 60,
            isSplittable: true
        )
        let occupiedRange = try TimeRange(
            start: date(day: 17, hour: 9),
            end: date(day: 17, hour: 16, minute: 30)
        )
        let fixedSession = Session(
            id: uuid(20),
            taskID: occupyingTask.id,
            zoneID: zone.id,
            timeRange: occupiedRange,
            placement: .userFixed,
            status: .planned
        )
        let snapshot = SchedulingSnapshot(
            planningDay: date(day: 17),
            timeZone: timeZone,
            zones: [zone],
            goals: [],
            tasks: [occupyingTask, overflowTask],
            sessions: [fixedSession]
        )

        let result = try DefaultScheduleEngine().makePlan(for: snapshot)

        XCTAssertTrue(result.todaySessionDrafts.isEmpty)
        let issue = try XCTUnwrap(result.issues.first)
        XCTAssertEqual(issue.taskID, overflowTask.id)
        XCTAssertEqual(issue.availableMinutes, 30)
        XCTAssertTrue(issue.resolutionCandidates.allSatisfy(\.requiresUserApproval))
        XCTAssertTrue(issue.resolutionCandidates.contains { $0.kind == .continuePastZone })
        XCTAssertTrue(issue.resolutionCandidates.contains { $0.kind == .splitAcrossDays })
        XCTAssertTrue(issue.resolutionCandidates.contains { $0.kind == .scheduleNextAvailableDay })
    }

    func testEngineAcceptsOverlappingUserFixedSessionsAndSchedulesAroundTheirUnion() throws {
        let zone = try makeZone(startHour: 9, endHour: 17)
        let firstFixedTask = try makeTask(id: uuid(1), zoneID: zone.id, minutes: 120)
        let secondFixedTask = try makeTask(id: uuid(2), zoneID: zone.id, minutes: 120)
        let taskToSchedule = try makeTask(id: uuid(3), zoneID: zone.id, minutes: 60)
        let sessions = [
            Session(
                id: uuid(20),
                taskID: firstFixedTask.id,
                zoneID: zone.id,
                timeRange: try TimeRange(
                    start: date(day: 17, hour: 9),
                    end: date(day: 17, hour: 11)
                ),
                placement: .userFixed,
                status: .planned
            ),
            Session(
                id: uuid(21),
                taskID: secondFixedTask.id,
                zoneID: zone.id,
                timeRange: try TimeRange(
                    start: date(day: 17, hour: 10),
                    end: date(day: 17, hour: 12)
                ),
                placement: .userFixed,
                status: .planned
            ),
        ]
        let snapshot = SchedulingSnapshot(
            planningDay: date(day: 17),
            timeZone: timeZone,
            zones: [zone],
            goals: [],
            tasks: [firstFixedTask, secondFixedTask, taskToSchedule],
            sessions: sessions
        )

        let result = try DefaultScheduleEngine().makePlan(for: snapshot)

        XCTAssertEqual(result.todaySessionDrafts.count, 1)
        XCTAssertEqual(result.todaySessionDrafts.first?.timeRange.start, date(day: 17, hour: 12))
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testDependencyIsScheduledAfterItsPredecessor() throws {
        let zone = try makeZone(startHour: 9, endHour: 17)
        let predecessor = try makeTask(id: uuid(1), zoneID: zone.id, minutes: 60)
        let successor = try makeTask(
            id: uuid(2),
            zoneID: zone.id,
            minutes: 60,
            dependencyIDs: [predecessor.id]
        )
        let snapshot = SchedulingSnapshot(
            planningDay: date(day: 17),
            timeZone: timeZone,
            zones: [zone],
            goals: [],
            tasks: [successor, predecessor],
            sessions: []
        )

        let result = try DefaultScheduleEngine().makePlan(for: snapshot)

        XCTAssertEqual(result.todaySessionDrafts.map(\.taskID), [predecessor.id, successor.id])
        XCTAssertEqual(result.todaySessionDrafts[0].timeRange.end, result.todaySessionDrafts[1].timeRange.start)
    }

    func testDependencyCycleIsRejected() throws {
        let zone = try makeZone(startHour: 9, endHour: 17)
        let firstID = uuid(1)
        let secondID = uuid(2)
        let first = try makeTask(
            id: firstID,
            zoneID: zone.id,
            minutes: 60,
            dependencyIDs: [secondID]
        )
        let second = try makeTask(
            id: secondID,
            zoneID: zone.id,
            minutes: 60,
            dependencyIDs: [firstID]
        )

        XCTAssertThrowsError(try StableTaskDependencySorter().order([first, second])) { error in
            XCTAssertEqual(
                error as? SchedulingError,
                .dependencyCycle(taskIDs: [firstID, secondID])
            )
        }
    }

    func testOvernightZoneEndsOnFollowingDay() throws {
        let zone = try makeZone(startHour: 21, endHour: 0)

        let range = try CalendarZoneWindowResolver().window(
            for: zone,
            on: date(day: 17),
            in: timeZone
        )

        XCTAssertEqual(range.start, date(day: 17, hour: 21))
        XCTAssertEqual(range.end, date(day: 18, hour: 0))
        XCTAssertEqual(range.durationMinutes, 180)
    }

    private func makeZone(startHour: Int, endHour: Int) throws -> Zone {
        try Zone(
            id: uuid(10),
            name: "Work",
            color: ZoneColor(hex: "#112233"),
            startTime: LocalTime(hour: startHour, minute: 0),
            endTime: LocalTime(hour: endHour, minute: 0)
        )
    }

    private func makeTask(
        id: UUID,
        zoneID: UUID,
        minutes: Int,
        isSplittable: Bool = false,
        dependencyIDs: Set<UUID> = []
    ) throws -> AwanTask {
        try AwanTask(
            id: id,
            zoneID: zoneID,
            duration: TaskDuration(minutes: minutes),
            isSplittable: isSplittable,
            dependencyIDs: dependencyIDs
        )
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(year: 2026, month: 7, day: day, hour: hour, minute: minute)
        ) ?? .distantPast
    }

    private func uuid(_ value: UInt8) -> UUID {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, value))
    }
}
