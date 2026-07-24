import Domain
import Foundation
import XCTest
@testable import Data

final class DefaultTemplateRepositoryTests: XCTestCase {
    func testCreateWeeklyTemplateCachesRemoteTemplateAndZoneIDs() async throws {
        let remoteTemplateID = UUID()
        let remoteZoneID = UUID()
        let draftZone = try Zone(
            id: UUID(),
            name: "Work",
            color: ZoneColor(hex: "#336699"),
            startTime: LocalTime(hour: 9, minute: 0),
            endTime: LocalTime(hour: 17, minute: 0)
        )
        let response = TemplateResponseDTO(
            id: remoteTemplateID,
            name: "Server Weekly Zones",
            daysOfWeek: [
                "MONDAY",
                "TUESDAY",
                "WEDNESDAY",
                "THURSDAY",
                "FRIDAY",
                "SATURDAY",
                "SUNDAY"
            ],
            zones: [
                ZoneResponseDTO(
                    id: remoteZoneID,
                    name: draftZone.name,
                    startTime: "09:00:00",
                    endTime: "17:00:00",
                    color: draftZone.color.hex,
                    templateId: remoteTemplateID,
                    templateOverrideId: nil
                )
            ]
        )
        let localDataSource = LocalTemplateDataSourceSpy()
        let repository = DefaultTemplateRepository(
            remoteDataSource: RemoteTemplateDataSourceStub(response: response),
            localDataSource: localDataSource
        )

        try await repository.createWeeklyTemplate(zones: [draftZone])

        let cachedTemplate = await localDataSource.addedTemplate
        XCTAssertEqual(cachedTemplate?.id, remoteTemplateID)
        XCTAssertEqual(cachedTemplate?.name, response.name)
        XCTAssertEqual(cachedTemplate?.weekDays, Set(1...7))
        XCTAssertEqual(cachedTemplate?.zones.map(\.id), [remoteZoneID])
        XCTAssertNotEqual(cachedTemplate?.zones.first?.id, draftZone.id)
    }
}

private struct RemoteTemplateDataSourceStub: RemoteTemplateDataSourceProtocol {
    let response: TemplateResponseDTO

    func createTemplate(request: CreateTemplateRequestDTO) async throws -> TemplateResponseDTO {
        response
    }

    func listTemplates() async throws -> [TemplateResponseDTO] {
        throw TestError.unimplemented
    }

    func getTemplate(templateID: UUID) async throws -> TemplateResponseDTO {
        throw TestError.unimplemented
    }

    func updateTemplate(
        templateID: UUID,
        request: UpdateTemplateRequestDTO
    ) async throws -> TemplateResponseDTO {
        throw TestError.unimplemented
    }

    func deleteTemplate(templateID: UUID) async throws {
        throw TestError.unimplemented
    }

    func addZone(
        templateID: UUID,
        request: AddZoneRequestDTO
    ) async throws -> ZoneResponseDTO {
        throw TestError.unimplemented
    }

    func getZones(templateID: UUID) async throws -> [ZoneResponseDTO] {
        throw TestError.unimplemented
    }
}

private actor LocalTemplateDataSourceSpy: LocalTemplateDataSource {
    private(set) var addedTemplate: TemplateData?

    func fetchTemplates() async throws -> [TemplateData] {
        []
    }

    func fetchTemplate(forWeekDay weekDay: Int) async throws -> TemplateData? {
        nil
    }

    func addTemplate(_ template: TemplateData) async throws {
        addedTemplate = template
    }

    func updateTemplate(_ template: TemplateData) async throws {}

    func deleteTemplate(id: UUID) async throws {}

    func deleteAllTemplates() async throws {}
}

private enum TestError: Error {
    case unimplemented
}
