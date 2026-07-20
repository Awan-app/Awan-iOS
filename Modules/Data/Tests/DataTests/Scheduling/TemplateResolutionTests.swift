import Darwin
import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class TemplateResolutionTests: XCTestCase {
    func testTemplateWeekDaysAreNormalizedAndResolved() async throws {
        let system = try makeSystem()
        let zone = try makeZone(name: "Weekday")
        let monday = try date(year: 2026, month: 7, day: 20)
        try await system.templateSource.addTemplate(
            TemplateData(
                id: UUID(),
                name: "Weekdays",
                weekDays: [2, 3, 4, 5, 6],
                zones: [zone]
            )
        )

        let zones = try await system.repository.fetchZones(for: monday)
        let templates = try await system.templateSource.fetchTemplates()
        let context = ModelContext(system.container)
        let persisted = try context.fetch(
            FetchDescriptor<TemplateModel>()
        )
        XCTAssertEqual(zones, [zone])
        XCTAssertEqual(templates.first?.weekDays, [2, 3, 4, 5, 6])
        XCTAssertEqual(persisted.first?.weekDaysRaw, [2, 3, 4, 5, 6])
    }

    func testOverrideWinsEvenWhenItHasNoZones() async throws {
        let system = try makeSystem()
        let day = try date(year: 2026, month: 7, day: 20)
        try await system.templateSource.addTemplate(
            TemplateData(
                id: UUID(),
                name: "Monday",
                weekDays: [2],
                zones: [try makeZone(name: "Template")]
            )
        )
        try await system.overrideSource.addTemplateOverride(
            TemplateOverrideData(
                id: UUID(),
                name: "Day off",
                dateOfDay: day,
                zones: []
            )
        )

        let zones = try await system.repository.fetchZones(for: day)
        XCTAssertTrue(zones.isEmpty)
    }

    func testTemplateOverlapAndInvalidWeekDaysAreRejected() async throws {
        let system = try makeSystem()
        try await system.templateSource.addTemplate(
            TemplateData(id: UUID(), name: "First", weekDays: [2, 3], zones: [])
        )

        await XCTAssertThrowsErrorAsync {
            try await system.templateSource.addTemplate(
                TemplateData(id: UUID(), name: "Second", weekDays: [3, 4], zones: [])
            )
        }
        await XCTAssertThrowsErrorAsync {
            try await system.templateSource.addTemplate(
                TemplateData(id: UUID(), name: "Invalid", weekDays: [], zones: [])
            )
        }
        await XCTAssertThrowsErrorAsync {
            try await system.templateSource.addTemplate(
                TemplateData(id: UUID(), name: "Invalid", weekDays: [8], zones: [])
            )
        }

        let nonOverlapping = TemplateData(
            id: UUID(),
            name: "Initially valid",
            weekDays: [4],
            zones: []
        )
        try await system.templateSource.addTemplate(nonOverlapping)
        await XCTAssertThrowsErrorAsync {
            try await system.templateSource.updateTemplate(
                TemplateData(
                    id: nonOverlapping.id,
                    name: nonOverlapping.name,
                    weekDays: [2],
                    zones: []
                )
            )
        }
    }

    func testUpdatingTemplateReconcilesAndDeletingRemovesZones() async throws {
        let system = try makeSystem()
        let templateID = UUID()
        let retained = try makeZone(name: "Retained")
        let removed = try makeZone(name: "Removed")
        try await system.templateSource.addTemplate(
            TemplateData(
                id: templateID,
                name: "Template",
                weekDays: [2],
                zones: [retained, removed]
            )
        )
        let changed = Zone(
            id: retained.id,
            name: "Changed",
            color: retained.color,
            startTime: retained.startTime,
            endTime: retained.endTime
        )

        try await system.templateSource.updateTemplate(
            TemplateData(
                id: templateID,
                name: "Updated",
                weekDays: [2],
                zones: [changed]
            )
        )
        let updatedZones = try await system.repository.fetchZones(
            for: date(year: 2026, month: 7, day: 20)
        )
        XCTAssertEqual(updatedZones, [changed])

        try await system.templateSource.deleteTemplate(id: templateID)
        let remainingZones = try await system.repository.fetchZones(
            for: date(year: 2026, month: 7, day: 20)
        )
        XCTAssertTrue(remainingZones.isEmpty)
        let context = ModelContext(system.container)
        let persistedZones = try context.fetch(FetchDescriptor<ZoneModel>())
        XCTAssertTrue(persistedZones.isEmpty)
    }

    func testOverrideMutationRulesAndZoneReconciliation() async throws {
        let system = try makeSystem()
        let overrideID = UUID()
        let day = try date(year: 2026, month: 7, day: 20)
        let retained = try makeZone(name: "Retained")
        let removed = try makeZone(name: "Removed")
        try await system.overrideSource.addTemplateOverride(
            TemplateOverrideData(
                id: overrideID,
                name: "Override",
                dateOfDay: day,
                zones: [retained, removed]
            )
        )

        await XCTAssertThrowsErrorAsync {
            try await system.overrideSource.addTemplateOverride(
                TemplateOverrideData(
                    id: UUID(),
                    name: "Duplicate date",
                    dateOfDay: day,
                    zones: []
                )
            )
        } verify: { error in
            XCTAssertEqual(
                error as? SchedulingPersistenceError,
                .duplicateOverrideDate(LocalDateKey.value(for: day))
            )
        }

        let changed = Zone(
            id: retained.id,
            name: "Changed",
            color: retained.color,
            startTime: retained.startTime,
            endTime: retained.endTime
        )
        try await system.overrideSource.updateTemplateOverride(
            TemplateOverrideData(
                id: overrideID,
                name: "Updated",
                dateOfDay: day,
                zones: [changed]
            )
        )
        let updatedZones = try await system.repository.fetchZones(for: day)
        XCTAssertEqual(updatedZones, [changed])

        try await system.overrideSource.deleteTemplateOverride(id: overrideID)
        let remainingZones = try await system.repository.fetchZones(for: day)
        XCTAssertTrue(remainingZones.isEmpty)
        let context = ModelContext(system.container)
        let persistedZones = try context.fetch(FetchDescriptor<ZoneModel>())
        XCTAssertTrue(persistedZones.isEmpty)
    }

    func testSundayAndSaturdayTemplatesUseFoundationWeekDays() async throws {
        let system = try makeSystem()
        let sundayZone = try makeZone(name: "Sunday")
        let saturdayZone = try makeZone(name: "Saturday")
        try await system.templateSource.addTemplate(
            TemplateData(id: UUID(), name: "Sunday", weekDays: [1], zones: [sundayZone])
        )
        try await system.templateSource.addTemplate(
            TemplateData(id: UUID(), name: "Saturday", weekDays: [7], zones: [saturdayZone])
        )

        let sundayZones = try await system.repository.fetchZones(
            for: date(year: 2026, month: 7, day: 19)
        )
        let saturdayZones = try await system.repository.fetchZones(
            for: date(year: 2026, month: 7, day: 25)
        )
        XCTAssertEqual(sundayZones, [sundayZone])
        XCTAssertEqual(saturdayZones, [saturdayZone])
    }

    func testNoTemplateOrOverrideReturnsNoZones() async throws {
        let system = try makeSystem()
        let zones = try await system.repository.fetchZones(
            for: date(year: 2026, month: 7, day: 20)
        )
        XCTAssertTrue(zones.isEmpty)
    }

    func testResolutionUsesDeviceTimeZoneForDateKeys() async throws {
        let previousTZ = getenv("TZ").map { String(cString: $0) }
        setenv("TZ", "Pacific/Kiritimati", 1)
        tzset()
        NSTimeZone.resetSystemTimeZone()
        defer {
            if let previousTZ {
                setenv("TZ", previousTZ, 1)
            } else {
                unsetenv("TZ")
            }
            tzset()
            NSTimeZone.resetSystemTimeZone()
        }

        let system = try makeSystem()
        let zone = try makeZone(name: "Local Monday")
        let overrideDate = try isoDate("2026-07-19T11:30:00Z")
        let requestedDate = try isoDate("2026-07-20T09:30:00Z")
        try await system.overrideSource.addTemplateOverride(
            TemplateOverrideData(
                id: UUID(),
                name: "Local day",
                dateOfDay: overrideDate,
                zones: [zone]
            )
        )

        let zones = try await system.repository.fetchZones(for: requestedDate)
        XCTAssertEqual(zones, [zone])
    }

    func testAmbiguousTemplatesAndInvalidZoneOwnershipFailResolution() async throws {
        let ambiguous = try makeSystem()
        do {
            let context = ModelContext(ambiguous.container)
            context.insert(
                TemplateModel(id: UUID(), name: "First", createdAt: Date(), weekDaysRaw: [2])
            )
            context.insert(
                TemplateModel(id: UUID(), name: "Second", createdAt: Date(), weekDaysRaw: [2])
            )
            try context.save()
        }
        let monday = try date(year: 2026, month: 7, day: 20)
        await XCTAssertThrowsErrorAsync {
            _ = try await ambiguous.repository.fetchZones(for: monday)
        } verify: { error in
            XCTAssertEqual(
                error as? SchedulingPersistenceError,
                .overlappingTemplateWeekDays([2])
            )
        }

        let invalidOwnership = try makeSystem()
        let invalidZoneID = UUID()
        do {
            let context = ModelContext(invalidOwnership.container)
            context.insert(
                ZoneModel(
                    id: invalidZoneID,
                    name: "Orphan",
                    colorHex: "#FFFFFF",
                    startHour: 9,
                    startMinute: 0,
                    endHour: 10,
                    endMinute: 0,
                    templateID: nil,
                    templateOverrideID: nil
                )
            )
            try context.save()
        }
        await XCTAssertThrowsErrorAsync {
            _ = try await invalidOwnership.repository.fetchZones(for: monday)
        } verify: { error in
            XCTAssertEqual(
                error as? SchedulingPersistenceError,
                .invalidZoneOwnership(invalidZoneID)
            )
        }
    }

    private struct System {
        let container: ModelContainer
        let repository: DefaultZoneRepository
        let templateSource: SwiftDataTemplateDataSource
        let overrideSource: SwiftDataTemplateOverrideDataSource
    }

    private func makeSystem() throws -> System {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let zoneSource = SwiftDataZoneDataSource(modelContainer: container)
        let templateSource = SwiftDataTemplateDataSource(modelContainer: container)
        let overrideSource = SwiftDataTemplateOverrideDataSource(modelContainer: container)
        return System(
            container: container,
            repository: DefaultZoneRepository(
                zoneDataSource: zoneSource,
                templateDataSource: templateSource,
                templateOverrideDataSource: overrideSource
            ),
            templateSource: templateSource,
            overrideSource: overrideSource
        )
    }

    private func makeZone(name: String) throws -> Zone {
        try Zone(
            id: UUID(),
            name: name,
            color: ZoneColor(hex: "#FFFFFF"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
    }

    private func date(year: Int, month: Int, day: Int) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
            throw SchedulingError.invalidTimeRange
        }
        return date
    }

    private func isoDate(_ value: String) throws -> Date {
        guard let date = ISO8601DateFormatter().date(from: value) else {
            throw SchedulingError.invalidTimeRange
        }
        return date
    }
}
