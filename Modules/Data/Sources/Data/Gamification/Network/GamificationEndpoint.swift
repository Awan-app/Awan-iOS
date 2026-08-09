//
//  GamificationEndpoint.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//
import AwaNetwork

enum GamificationEndpoint: APIEndpoint {
    case getProgress
    case getStoreItems(type: String)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getProgress:
            return "/gamification/progress"
        case .getStoreItems:
            return "/store/items"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryParameters: [String: String]? {
        switch self {
        case .getProgress:
            return nil
        case let .getStoreItems(type):
            return ["type": type]
        }
    }

    var body: (any Encodable)? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
