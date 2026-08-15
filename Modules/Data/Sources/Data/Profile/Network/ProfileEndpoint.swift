//
//  ProfileEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum ProfileEndpoint: APIEndpoint {

    case getProfile
    case getMCPConnectionDetails
    case updateName(UpdateNameRequestDTO)
    case updateBirthDate(UpdateBirthDateRequestDTO)
    case updateProfilePartial(UpdateProfilePartialRequestDTO)
    case updateProfilePicture

    case updateTimezone(UpdateTimezoneRequestDTO)
    case updateSessionSettings(UpdateSessionSettingsRequestDTO)
    case updateSleepSchedule(UpdateSleepScheduleRequestDTO)
    case updateSchedulingType(UpdateSchedulingTypeRequestDTO)

    case incrementStreak
    case resetStreak
    case awardPoints(UpdatePointsRequestDTO)
    case deductPoints(UpdatePointsRequestDTO)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getProfile, .updateProfilePartial:
            return "/users/me"
        case .getMCPConnectionDetails:
            return "/mcp/settings/connection-details"
        case .updateProfilePicture:
            return "/users/me/profile/picture"
        case .updateName:
            return "/users/me/profile/name"
        case .updateBirthDate:
            return "/users/me/profile/birth-date"
        case .updateTimezone:
            return "/users/me/preferences/timezone"
        case .updateSessionSettings:
            return "/users/me/preferences/session"
        case .updateSleepSchedule:
            return "/users/me/preferences/sleep-schedule"
        case .updateSchedulingType:
            return "/users/me/preferences/scheduling-type"
        case .incrementStreak:
            return "/users/me/streak/increment"
        case .resetStreak:
            return "/users/me/streak/reset"
        case .awardPoints:
            return "/users/me/points/award"
        case .deductPoints:
            return "/users/me/points/deduct"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProfile, .getMCPConnectionDetails:
            return .get
        case .updateName, .updateBirthDate, .updateProfilePartial, .updateProfilePicture,
             .updateTimezone, .updateSessionSettings, .updateSleepSchedule, .updateSchedulingType,
             .incrementStreak, .resetStreak, .awardPoints, .deductPoints:
            return .patch
        }
    }

    var queryParameters: [String: String]? {
        nil
    }

    var body: (any Encodable)? {
        switch self {
        case .updateName(let request): return request
        case .updateBirthDate(let request): return request
        case .updateProfilePartial(let request): return request
        case .updateTimezone(let request): return request
        case .updateSessionSettings(let request): return request
        case .updateSleepSchedule(let request): return request
        case .updateSchedulingType(let request): return request
        case .awardPoints(let request): return request
        case .deductPoints(let request): return request
        case .getProfile, .getMCPConnectionDetails, .incrementStreak, .resetStreak, .updateProfilePicture: return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
