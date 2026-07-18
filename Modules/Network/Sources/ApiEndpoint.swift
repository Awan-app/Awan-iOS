//
//  ApiEndpoint.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//


import Foundation

public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String]? { get }
    var body: (any Encodable)? { get }
    var headers: [String: String] { get }
}

public extension APIEndpoint {
    var body: (any Encodable)? { nil }
    var headers: [String: String] { [:] }

    var fullURL: URL? {
        var components = URLComponents(string: baseURL + path)
        if let queryParameters {
            components?.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        return components?.url
    }
}
