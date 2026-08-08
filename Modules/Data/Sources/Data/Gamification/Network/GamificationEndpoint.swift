//
//  GamificationEndpoint.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//
import AwaNetwork

enum GamificationEndpoint: APIEndpoint {
    case getProgress

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        "/gamification/progress"
    }

    var method: HTTPMethod {
        .get
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
