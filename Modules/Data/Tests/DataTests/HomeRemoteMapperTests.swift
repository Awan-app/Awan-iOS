import Domain
import Foundation
import XCTest
@testable import Data

final class HomeRemoteMapperTests: XCTestCase {
    func testTaskStatusesMapSemanticallyAndPreserveZone() throws {
        let zoneID = UUID()
        let values: [(String, TaskStatus)] = [
            ("SCHEDULED", .pending),
            ("IN_PROGRESS", .inProgress),
            ("COMPLETED", .completed),
            ("CANCELLED", .cancelled),
        ]

        for (rawStatus, expected) in values {
            let mapped = try HomeRemoteMapper.task(
                taskDTO(status: rawStatus),
                zoneID: zoneID,
                defaultDuration: 45
            )
            XCTAssertEqual(mapped.status, expected)
            XCTAssertEqual(mapped.zoneID, zoneID)
            XCTAssertEqual(mapped.duration.minutes, 45)
        }
    }

    func testSessionStatusesAndTimesUseProfileTimezone() throws {
        let taskID = UUID()
        let session = try HomeRemoteMapper.session(
            SessionResponseDTO(
                id: UUID(),
                start: "2026-07-22T10:30:00",
                end: "2026-07-22T11:30:00",
                status: "IN_PROGRESS",
                locked: true,
                zoneId: UUID(),
                taskID: taskID
            ),
            timeZoneID: "Africa/Cairo"
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Africa/Cairo") ?? .gmt

        XCTAssertEqual(session.taskID, taskID)
        XCTAssertEqual(session.status, .planned)
        XCTAssertTrue(session.blocking)
        XCTAssertEqual(calendar.component(.hour, from: session.timeRange.start), 10)
        XCTAssertEqual(
            HomeRemoteMapper.formatDateTime(
                session.timeRange.start,
                timeZoneID: "Africa/Cairo"
            ),
            "2026-07-22T10:30:00"
        )
    }

    func testZoneWithoutRemoteColorUsesStableFallback() throws {
        let zone = try HomeRemoteMapper.zone(
            ZoneResponseDTO(
                id: UUID(),
                name: "Focus",
                startTime: "09:00:00",
                endTime: "11:00:00",
                color: nil,
                templateId: nil,
                templateOverrideId: nil
            )
        )

        XCTAssertEqual(zone.color.hex, "#6C63FF")
    }

    func testProfileRequiresOnboardingFields() {
        XCTAssertThrowsError(
            try HomeRemoteMapper.profile(profileDTO(firstName: nil))
        )
    }

    private func taskDTO(status: String) -> TaskInfoResponseDTO {
        TaskInfoResponseDTO(
            id: UUID(),
            title: "Task",
            description: nil,
            status: status,
            goalID: nil,
            estimatedDuration: nil,
            mandatory: false,
            estimatedPoints: 0,
            isSplittable: false,
            dependencyIDs: []
        )
    }

    private func profileDTO(firstName: String?) -> UserProfileResponseDTO {
        UserProfileResponseDTO(
            id: UUID(),
            email: "home@awan.app",
            firstName: firstName,
            lastName: "User",
            birthDate: "2000-01-01",
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferencesDTO(
                timezone: "UTC",
                preferredSessionDuration: 45,
                bufferBetweenSessions: 10,
                wakeupTime: "08:00:00",
                sleepTime: "00:00:00",
                schedulingType: "FLEXIBLE"
            )
        )
    }
}
