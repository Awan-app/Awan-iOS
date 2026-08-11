//
//  GamificationEndpoint.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//
import AwaNetwork

enum GamificationEndpoint: APIEndpoint {
    case getProgress
    case getWheelConfig
    case spinWheel
    case activityDates(startDate: String, endDate: String)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getProgress: "/gamification/progress"
        case .getWheelConfig: "/gamification/wheel/config"
        case .spinWheel: "/gamification/wheel/spin"
        case .activityDates: "/gamification/activity-dates"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProgress, .getWheelConfig, .activityDates: .get
        case .spinWheel: .post
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .activityDates(startDate, endDate):
            ["startDate": startDate, "endDate": endDate]
        case .getProgress, .getWheelConfig, .spinWheel:
            nil
        }
    }

    var body: (any Encodable)? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
