//
//  RemoteProfileDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public protocol RemoteProfileDataSource: Sendable {
    func getProfile() async throws -> UserProfileResponseDTO
    func updateName(_ request: UpdateNameRequestDTO) async throws -> UserProfileResponseDTO
    func updateBirthDate(_ request: UpdateBirthDateRequestDTO) async throws -> UserProfileResponseDTO
    func updateProfilePartial(_ request: UpdateProfilePartialRequestDTO) async throws -> UserProfileResponseDTO

    func updateTimezone(_ request: UpdateTimezoneRequestDTO) async throws -> UserProfileResponseDTO
    func updateSessionSettings(_ request: UpdateSessionSettingsRequestDTO) async throws -> UserProfileResponseDTO
    func updateSleepSchedule(_ request: UpdateSleepScheduleRequestDTO) async throws -> UserProfileResponseDTO
    func updateSchedulingType(_ request: UpdateSchedulingTypeRequestDTO) async throws -> UserProfileResponseDTO

    func incrementStreak() async throws -> UserProgressResponseDTO
    func resetStreak() async throws -> UserProgressResponseDTO
    func awardPoints(_ request: UpdatePointsRequestDTO) async throws -> UserProgressResponseDTO
    func deductPoints(_ request: UpdatePointsRequestDTO) async throws -> UserProgressResponseDTO
}

public final class DefaultRemoteProfileDataSource: RemoteProfileDataSource {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getProfile() async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.getProfile)
    }

    public func updateName(_ request: UpdateNameRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateName(request))
    }

    public func updateBirthDate(_ request: UpdateBirthDateRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateBirthDate(request))
    }

    public func updateProfilePartial(_ request: UpdateProfilePartialRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateProfilePartial(request))
    }

    public func updateTimezone(_ request: UpdateTimezoneRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateTimezone(request))
    }

    public func updateSessionSettings(_ request: UpdateSessionSettingsRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateSessionSettings(request))
    }

    public func updateSleepSchedule(_ request: UpdateSleepScheduleRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateSleepSchedule(request))
    }

    public func updateSchedulingType(_ request: UpdateSchedulingTypeRequestDTO) async throws -> UserProfileResponseDTO {
        try await networkService.request(ProfileEndpoint.updateSchedulingType(request))
    }

    public func incrementStreak() async throws -> UserProgressResponseDTO {
        try await networkService.request(ProfileEndpoint.incrementStreak)
    }

    public func resetStreak() async throws -> UserProgressResponseDTO {
        try await networkService.request(ProfileEndpoint.resetStreak)
    }

    public func awardPoints(_ request: UpdatePointsRequestDTO) async throws -> UserProgressResponseDTO {
        try await networkService.request(ProfileEndpoint.awardPoints(request))
    }

    public func deductPoints(_ request: UpdatePointsRequestDTO) async throws -> UserProgressResponseDTO {
        try await networkService.request(ProfileEndpoint.deductPoints(request))
    }
}
