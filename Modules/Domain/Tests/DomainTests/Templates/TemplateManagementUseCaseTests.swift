import Foundation
import XCTest
@testable import Domain

final class TemplateManagementUseCaseTests: XCTestCase {
    func testCreateTemplateRejectsBlankNameBeforeRepositoryCall() async {
        let repository = TemplateRepositorySpy()
        let useCase = DefaultCreateTemplateUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                name: "  ",
                daysOfWeek: [.monday],
                zones: []
            )
            XCTFail("Expected blank template name to fail")
        } catch {
            XCTAssertEqual(error as? TemplateManagementError, .templateNameRequired)
        }

        let callCount = await repository.createCallCount
        XCTAssertEqual(callCount, 0)
    }

    func testCreateTemplateRejectsMissingWeekdayBeforeRepositoryCall() async {
        let repository = TemplateRepositorySpy()
        let useCase = DefaultCreateTemplateUseCase(repository: repository)

        do {
            _ = try await useCase.execute(name: "Work", daysOfWeek: [], zones: [])
            XCTFail("Expected missing weekday to fail")
        } catch {
            XCTAssertEqual(error as? TemplateManagementError, .templateWeekdayRequired)
        }

        let callCount = await repository.createCallCount
        XCTAssertEqual(callCount, 0)
    }

    func testCreateOverrideRejectsDuplicateDate() async throws {
        let date = try TemplateOverrideDate(year: 2026, month: 8, day: 3)
        let existing = TemplateOverride(id: UUID(), name: "Existing", dateOfDay: date, zones: [])
        let repository = TemplateOverrideRepositorySpy(overrides: [existing])
        let useCase = DefaultCreateTemplateOverrideUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                name: "Special day",
                dateOfDay: date,
                minimumDate: try TemplateOverrideDate(year: 2026, month: 8, day: 2),
                zones: []
            )
            XCTFail("Expected duplicate override date to fail")
        } catch {
            XCTAssertEqual(error as? TemplateManagementError, .overrideDateAlreadyExists)
        }

        let callCount = await repository.createCallCount
        XCTAssertEqual(callCount, 0)
    }

    func testWeeklyZonesResolvesTemplateForDatesWeekday() throws {
        let mondayZone = try makeZone(name: "Monday")
        let tuesdayZone = try makeZone(name: "Tuesday")
        let templates = [
            Template(id: UUID(), name: "Monday", daysOfWeek: [.monday], zones: [mondayZone]),
            Template(id: UUID(), name: "Tuesday", daysOfWeek: [.tuesday], zones: [tuesdayZone])
        ]
        let date = try TemplateOverrideDate(year: 2026, month: 8, day: 3)

        let zones = DefaultManageDailyZoneScheduleUseCase().weeklyZones(
            for: date,
            timeZone: TimeZone(identifier: "Africa/Cairo")!,
            templates: templates
        )

        XCTAssertEqual(zones, [mondayZone])
    }

    private func makeZone(name: String) throws -> Zone {
        Zone(
            id: UUID(),
            name: name,
            color: try ZoneColor(hex: "#1A73E8"),
            startTime: try LocalTime(hour: 9, minute: 0),
            endTime: try LocalTime(hour: 10, minute: 0),
            category: nil
        )
    }
}

private actor TemplateRepositorySpy: TemplateRepository {
    private(set) var createCallCount = 0

    func createTemplate(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template {
        createCallCount += 1
        return Template(id: UUID(), name: name, daysOfWeek: daysOfWeek, zones: zones)
    }

    func listTemplates() async throws -> [Template] { [] }

    func updateBulkTemplate(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> Template {
        fatalError("Not used in these tests")
    }

    func updateTemplate(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template {
        fatalError("Not used in these tests")
    }

    func deleteTemplate(id: UUID) async throws {
        fatalError("Not used in these tests")
    }
}

private actor TemplateOverrideRepositorySpy: TemplateOverrideRepository {
    private let overrides: [TemplateOverride]
    private(set) var createCallCount = 0

    init(overrides: [TemplateOverride]) {
        self.overrides = overrides
    }

    func createTemplateOverride(
        name: String,
        dateOfDay: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride {
        createCallCount += 1
        return TemplateOverride(id: UUID(), name: name, dateOfDay: dateOfDay, zones: zones ?? [])
    }

    func listTemplateOverrides() async throws -> [TemplateOverride] {
        overrides
    }

    func updateTemplateOverride(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate
    ) async throws -> TemplateOverride {
        fatalError("Not used in these tests")
    }

    func updateBulkTemplateOverride(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> TemplateOverride {
        fatalError("Not used in these tests")
    }

    func deleteTemplateOverride(id: UUID) async throws {
        fatalError("Not used in these tests")
    }
}
