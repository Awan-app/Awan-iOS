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
        remoteDataSource: ZoneRemoteDataSourceStub()
    )
}

private actor ZoneProfileDataSourceStub: LocalUserProfileDataSource {
    func fetchProfile() -> UserProfile? { nil }
    func replaceProfile(_ profile: UserProfile) {}
}

private struct ZoneRemoteDataSourceStub: RemoteZoneDataSourceProtocol {
    func getZone(zoneId: UUID) throws -> ZoneResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func getZoneSessions(zoneId: UUID) throws -> [SessionResponseDTO] {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func getZonesByDate(date: String) throws -> [ZoneResponseDTO] {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func updateZone(
        zoneId: UUID,
        request: UpdateZoneRequestDTO
    ) throws -> ZoneResponseDTO {
        throw ZoneRepositoryTestError.unusedRemote
    }
    func deleteZone(zoneId: UUID) throws {
        throw ZoneRepositoryTestError.unusedRemote
    }
}

private enum ZoneRepositoryTestError: Error {
    case unusedRemote
}
