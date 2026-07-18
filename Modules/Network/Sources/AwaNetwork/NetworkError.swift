//
//  NetworkError.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation

// MARK: - NetworkError

/// All errors that can be thrown by ``NetworkClient``.
public enum NetworkError: Error, Sendable {
    /// The endpoint's `fullURL` computed property returned `nil`.
    case invalidURL

    /// Encoding the request body into JSON failed.
    case encodingFailed(any Error & Sendable)

    /// The server replied with a 4xx or 5xx status code.
    /// `apiError` carries the decoded standard error envelope when available.
    case httpError(statusCode: Int, apiError: APIErrorResponse?)

    /// The success response body could not be decoded into the expected type.
    case decodingFailed(any Error & Sendable)

    /// A transport-level or Alamofire session error occurred.
    case underlying(any Error & Sendable)

    /// The server returned 204 No Content where a body was expected, or
    /// the caller used `request(_:)` on a no-content endpoint.
    case noContent
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL could not be constructed."
        case .encodingFailed(let error):
            return "Request encoding failed: \(error.localizedDescription)"
        case .httpError(let statusCode, let apiError):
            if let message = apiError?.message {
                return message
            }
            return "Server returned an error with status code \(statusCode)."
        case .decodingFailed(let error):
            return "Response decoding failed: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        case .noContent:
            return "The server returned no content."
        }
    }
}

// MARK: - APIErrorResponse

/// The standard error envelope returned by all Awan API endpoints on 4xx / 5xx.
///
/// ```json
/// {
///   "message": "…",
///   "statusCode": 400,
///   "errorCode": "OTP_INVALID_CODE",
///   "info": { … },
///   "timestamp": "…"
/// }
/// ```
public struct APIErrorResponse: Decodable, Sendable {
    /// Human-readable description of the error.
    public let message: String
    /// Mirrors the HTTP status code.
    public let statusCode: Int
    /// Machine-readable error code constant.
    public let errorCode: APIErrorCode
    /// Optional metadata (remaining attempts, retry delay, validation errors, etc.)
    public let info: [String: JSONValue]?
    /// ISO-8601 timestamp from the server.
    public let timestamp: String?
}

// MARK: - APIErrorCode

/// Every documented error code from the Awan Authentication API contract.
///
/// Use the `unknown` case to handle future codes gracefully without breaking existing logic.
public enum APIErrorCode: RawRepresentable, Decodable, Sendable, Equatable {

    // MARK: OTP — Request endpoint
    /// 429 — Rate limit hit. Check `info["retryAfterSeconds"]`.
    case otpRateLimitExceeded

    // MARK: OTP — Both endpoints
    /// 422 — Invalid email format or missing / malformed fields.
    case validationError

    // MARK: OTP — Verify endpoint
    /// 400 — Wrong code. Check `info["remainingAttempts"]`.
    case otpInvalidCode
    /// 400 — OTP has expired or was never requested.
    case otpExpiredOrNotFound
    /// 400 — Account locked after 5 failed attempts; a new OTP must be requested.
    case otpLocked

    // MARK: Refresh Token endpoint
    /// 401 — Refresh token doesn't exist or device ID doesn't match.
    case refreshTokenInvalid
    /// 401 — Token is older than 30 days. User must log in again.
    case refreshTokenExpired
    /// 401 — Security alert: a previously revoked token was reused.
    ///        All active sessions are instantly revoked.
    case refreshTokenReuseDetected

    // MARK: Catch-all
    /// Any error code not listed in the current contract.
    case unknown(String)

    // MARK: RawRepresentable

    public typealias RawValue = String

    public init(rawValue: String) {
        switch rawValue {
        case "OTP_RATE_LIMIT_EXCEEDED":       self = .otpRateLimitExceeded
        case "VALIDATION_ERROR":              self = .validationError
        case "OTP_INVALID_CODE":              self = .otpInvalidCode
        case "OTP_EXPIRED_OR_NOT_FOUND":      self = .otpExpiredOrNotFound
        case "OTP_LOCKED":                    self = .otpLocked
        case "REFRESH_TOKEN_INVALID":         self = .refreshTokenInvalid
        case "REFRESH_TOKEN_EXPIRED":         self = .refreshTokenExpired
        case "REFRESH_TOKEN_REUSE_DETECTED":  self = .refreshTokenReuseDetected
        default:                              self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .otpRateLimitExceeded:          return "OTP_RATE_LIMIT_EXCEEDED"
        case .validationError:               return "VALIDATION_ERROR"
        case .otpInvalidCode:                return "OTP_INVALID_CODE"
        case .otpExpiredOrNotFound:          return "OTP_EXPIRED_OR_NOT_FOUND"
        case .otpLocked:                     return "OTP_LOCKED"
        case .refreshTokenInvalid:           return "REFRESH_TOKEN_INVALID"
        case .refreshTokenExpired:           return "REFRESH_TOKEN_EXPIRED"
        case .refreshTokenReuseDetected:     return "REFRESH_TOKEN_REUSE_DETECTED"
        case .unknown(let code):             return code
        }
    }
}

// MARK: - JSONValue

/// A type-safe representation of arbitrary JSON values used in `APIErrorResponse.info`.
///
/// Callers can pattern-match to extract typed metadata, for example:
/// ```swift
/// if case .int(let remaining) = apiError.info?["remainingAttempts"] {
///     print("Attempts left: \(remaining)")
/// }
/// ```
public indirect enum JSONValue: Decodable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let objectValue = try? container.decode([String: JSONValue].self) {
            self = .object(objectValue)
        } else if let arrayValue = try? container.decode([JSONValue].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported JSON value type"
                )
            )
        }
    }
}

// MARK: - EmptyResponse

/// Sentinel return type for endpoints that return **204 No Content**.
///
/// Pass this as the generic parameter `T` in ``NetworkServiceProtocol/request(_:)``
/// for endpoints with no response body — for example Logout:
///
/// ```swift
/// let _: EmptyResponse = try await networkService.request(AuthEndpoint.logout(deviceId: id))
/// ```
///
/// ``NetworkClient`` detects `EmptyResponse` and skips JSON decoding,
/// returning a value immediately when the server sends an empty body.
public struct EmptyResponse: Decodable, Sendable {
    public init() {}
    public init(from decoder: any Decoder) throws {}
}
