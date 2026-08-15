import Domain
import Foundation
import XCTest
@testable import Data

final class HomeRemoteMapperTests: XCTestCase {
    func testTaskStatusesMapSemanticallyAndPreserveCategory() throws {
        let categoryID = UUID()
        let values: [(String, TaskStatus)] = [
            ("DRAFTED", .drafted),
            ("ACTIVE", .active),
            ("SCHEDULED", .active),
            ("IN_PROGRESS", .active),
            ("COMPLETED", .completed),
            ("CANCELLED", .cancelled),
        ]

        for (rawStatus, expected) in values {
            let mapped = try HomeRemoteMapper.task(
                taskDTO(status: rawStatus, categoryID: categoryID),
                defaultDuration: 45
            )
            XCTAssertEqual(mapped.status, expected)
            XCTAssertEqual(mapped.category?.id, categoryID)
            XCTAssertEqual(mapped.category?.name, "Focus")
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
        let categoryID = UUID()
        let zone = try HomeRemoteMapper.zone(
            ZoneResponseDTO(
                id: UUID(),
                name: "Focus",
                startTime: "09:00:00",
                endTime: "11:00:00",
                color: nil,
                category: CategoryResponseDTO(id: categoryID, name: "Focus"),
                templateId: nil,
                templateOverrideId: nil
            )
        )

        XCTAssertEqual(zone.color.hex, "#6C63FF")
        XCTAssertEqual(zone.category, TaskCategory(id: categoryID, name: "Focus"))
    }

    func testTemplateResponseDecodesNestedZoneCategory() throws {
        let templateID = UUID()
        let zoneID = UUID()
        let categoryID = UUID()
        let json = """
        {
          "id": "\(templateID.uuidString)",
          "name": "Updated Work Week",
          "daysOfWeek": ["FRIDAY", "MONDAY", "WEDNESDAY"],
          "zones": [{
            "id": "\(zoneID.uuidString)",
            "name": "Evening Review",
            "startTime": "18:00:00",
            "endTime": "19:00:00",
            "color": "#FF9800",
            "category": {
              "id": "\(categoryID.uuidString)",
              "name": "Evening Review"
            },
            "templateId": "\(templateID.uuidString)",
            "templateOverrideId": null
          }]
        }
        """

        let response = try JSONDecoder().decode(
            TemplateResponseDTO.self,
            from: Data(json.utf8)
        )
        let zone = try HomeRemoteMapper.zone(try XCTUnwrap(response.zones.first))

        XCTAssertEqual(response.id, templateID)
        XCTAssertEqual(zone.id, zoneID)
        XCTAssertEqual(
            zone.category,
            TaskCategory(id: categoryID, name: "Evening Review")
        )
    }

    func testTemplateOverrideResponseDecodesNestedZoneCategory() throws {
        let overrideID = UUID()
        let zoneID = UUID()
        let categoryID = UUID()
        let json = """
        {
          "id": "\(overrideID.uuidString)",
          "name": "Special Day",
          "dateOfDay": "2026-07-29",
          "zones": [{
            "id": "\(zoneID.uuidString)",
            "name": "Morning Focus",
            "startTime": "09:00:00",
            "endTime": "11:00:00",
            "color": "#4CAF50",
            "category": {
              "id": "\(categoryID.uuidString)",
              "name": "Morning Focus"
            },
            "templateId": null,
            "templateOverrideId": "\(overrideID.uuidString)"
          }]
        }
        """

        let response = try JSONDecoder().decode(
            TemplateOverrideResponseDTO.self,
            from: Data(json.utf8)
        )
        let zone = try HomeRemoteMapper.zone(try XCTUnwrap(response.zones.first))

        XCTAssertEqual(response.id, overrideID)
        XCTAssertEqual(zone.id, zoneID)
        XCTAssertEqual(
            zone.category,
            TaskCategory(id: categoryID, name: "Morning Focus")
        )
    }

    func testProfileRequiresOnboardingFields() {
        XCTAssertThrowsError(
            try HomeRemoteMapper.profile(profileDTO(firstName: nil))
        )
    }

    private func taskDTO(status: String, categoryID: UUID) -> TaskInfoResponseDTO {
        TaskInfoResponseDTO(
            id: UUID(),
            title: "Task",
            description: nil,
            status: status,
            completedAt: status == "COMPLETED"
                ? "2026-08-10T06:07:40.829849069Z"
                : nil,
            goalID: nil,
            estimatedDuration: nil,
            mandatory: false,
            estimatedPoints: 0,
            isSplittable: false,
            dependencyIDs: [],
            category: CategoryResponseDTO(id: categoryID, name: "Focus")
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
            profilePictureUrl: nil,
            isNew: false,
            preferences: UserPreferencesDTO(
                timezone: "UTC",
                preferredSessionDuration: 45,
                bufferBetweenSessions: 10,
                wakeupTime: "08:00:00",
                sleepTime: "00:00:00",
                schedulingType: "FLEXIBLE"
            ),
            equippedItems: []
        )
    }
}
