//
//  NetworkServices.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation

/// Contract that any concrete network client must fulfil.
///
/// - `request(_:)` — for endpoints that return a decodable JSON body.
/// - `requestEmpty(_:)` — for endpoints that return 204 No Content (e.g. Logout).
public protocol NetworkServiceProtocol: Sendable {
    /// Performs an async request and decodes the response body into `T`.
    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T

    /// Performs an async request that expects a 204 No Content response.
    func requestEmpty(_ endpoint: any APIEndpoint) async throws
}

