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

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getProgress: "/gamification/progress"
        case .getWheelConfig: "/gamification/wheel/config"
        case .spinWheel: "/gamification/wheel/spin"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProgress, .getWheelConfig: .get
        case .spinWheel: .post
        }
    }

    var queryParameters: [String: String]? {
        nil
    }

    var body: (any Encodable)? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
