//
//  NetworkServices.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation

/// Contract that any concrete network client must fulfil.
///
/// One generic function handles **every** endpoint in the auth contract:
///
/// - JSON-body responses: pass any `Decodable` model as `T`.
/// - 204 No Content responses (e.g. Logout): use ``EmptyResponse`` as `T`.
///
/// ```swift
/// // JSON response
/// let result: OTPRequestResponseDTO = try await client.request(endpoint)
///
/// // 204 No Content (Logout)
/// let _: EmptyResponse = try await client.request(endpoint)
/// ```
public protocol NetworkServiceProtocol: Sendable {
    /// Performs an async network request and returns `T`.
    ///
    /// Use ``EmptyResponse`` as `T` for endpoints that return 204 No Content.
    ///
    /// - Parameter endpoint: Any value conforming to ``APIEndpoint``.
    /// - Returns: A decoded instance of `T`, or ``EmptyResponse`` for no-body responses.
    /// - Throws: ``NetworkError``
    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T
}
