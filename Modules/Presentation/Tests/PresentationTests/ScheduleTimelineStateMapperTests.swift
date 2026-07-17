import Domain
import Foundation
import XCTest
@testable import Presentation

final class ScheduleTimelineStateMapperTests: XCTestCase {
    private let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

    func testOnlyOverlappingSessionGroupSharesTimelineWidth() throws {
        let zone = try Zone(
            id: UUID(),
            name: "Work",
            color: ZoneColor(hex: "#4A90E2"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        let ranges = [
            (startHour: 9, startMinute: 0, endHour: 10, endMinute: 15),
            (startHour: 9, startMinute: 15, endHour: 10, endMinute: 15),
            (startHour: 10, startMinute: 15, endHour: 12, endMinute: 0),
            (startHour: 12, startMinute: 0, endHour: 15, endMinute: 0),
        ]
        let tasks = try ranges.indices.map { index in
            try AwanTask(
                id: UUID(),
                title: "Task \(index)",
                zoneID: zone.id,
                duration: TaskDuration(minutes: 60),
                isSplittable: false
            )
        }
        let sessions = try zip(tasks, ranges).map { task, range in
            Session(
                id: UUID(),
                taskID: task.id,
                zoneID: zone.id,
                timeRange: try TimeRange(
                    start: date(hour: range.startHour, minute: range.startMinute),
                    end: date(hour: range.endHour, minute: range.endMinute)
                ),
                blocking: true,
                status: .planned
            )
        }
        let content = ScheduleTimelineStateMapper(timeZone: timeZone).mapContent(
            workspace: ScheduleWorkspace(
                zones: [zone],
                goals: [],
                tasks: tasks,
                sessions: sessions
            ),
            selectedDay: date(hour: 0),
            today: date(hour: 0)
        )

        XCTAssertEqual(content.timelineItems.map(\.laneCount), [2, 2, 1, 1])
        XCTAssertEqual(content.timelineItems.map(\.lane), [0, 1, 0, 0])
    }

    private func date(hour: Int, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 20,
                hour: hour,
                minute: minute
            )
        ) ?? .distantPast
    }
}
