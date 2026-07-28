import Combine
import Domain
import Foundation
@testable import Data

func makeZoneRepository(
    zoneDataSource: any LocalZoneDataSource,
    templateDataSource: any LocalTemplateDataSource,
    templateOverrideDataSource: any LocalTemplateOverrideDataSource
) -> DefaultZoneRepository {
    DefaultZoneRepository(
        zoneDataSource: zoneDataSource,
        templateDataSource: templateDataSource,
        templateOverrideDataSource: templateOverrideDataSource,
        profileDataSource: ZoneProfileDataSourceStub(),
        remoteTemplateDataSource: ZoneRemoteTemplateDataSourceStub(),
        remoteTemplateOverrideDataSource: ZoneRemoteTemplateOverrideDataSourceStub()
    )
}

private actor ZoneProfileDataSourceStub: LocalUserProfileDataSource {
    nonisolated func observeProfile() -> AnyPublisher<UserProfile?, Error> {
        Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func fetchProfile() async throws -> UserProfile? { nil }
    func replaceProfile(_ profile: UserProfile) async throws {}
}

private struct ZoneRemoteTemplateDataSourceStub: RemoteTemplateDataSourceProtocol {
    func createTemplate(request: CreateTemplateRequestDTO) async throws -> TemplateResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func listTemplates() async throws -> [TemplateResponseDTO] { [] }
    func getTemplate(templateID: UUID) async throws -> TemplateResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func updateTemplate(
        templateID: UUID,
        request: UpdateTemplateRequestDTO
    ) async throws -> TemplateResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func deleteTemplate(templateID: UUID) async throws {}
    func addZone(
        templateID: UUID,
        request: AddZoneRequestDTO
    ) async throws -> ZoneResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func getZones(templateID: UUID) async throws -> [ZoneResponseDTO] { [] }
    func bulkUpdate(
        templateID: UUID,
        request: BulkUpdateZonesRequestDTO
    ) async throws -> [ZoneResponseDTO] { [] }
}

private struct ZoneRemoteTemplateOverrideDataSourceStub:
    RemoteTemplateOverrideDataSourceProtocol {
    func createOverride(
        request: CreateTemplateOverrideRequestDTO
    ) async throws -> TemplateOverrideResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func listOverrides() async throws -> [TemplateOverrideResponseDTO] { [] }
    func getOverride(overrideId: UUID) async throws -> TemplateOverrideResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func updateOverride(
        overrideId: UUID,
        request: UpdateTemplateOverrideRequestDTO
    ) async throws -> TemplateOverrideResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func deleteOverride(overrideId: UUID) async throws {}
    func addZone(
        overrideId: UUID,
        request: AddZoneRequestDTO
    ) async throws -> ZoneResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func getZones(overrideId: UUID) async throws -> [ZoneResponseDTO] { [] }
}

private enum ZoneRepositoryTestError: Error {
    case unusedRemote
}
