//
//  NetworkError.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation
public enum NetworkError: Error, Sendable {
    
    case invalidURL
    case encodingFailed(any Error & Sendable)
    case httpError(statusCode: Int, apiError: APIErrorResponse?)
    case decodingFailed(any Error & Sendable)
    case underlying(any Error & Sendable)
    case noContent
}


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

public struct APIErrorResponse: Decodable, Sendable {
    public let message: String
    public let statusCode: Int
    public let errorCode: APIErrorCode
    public let info: APIErrorInfo?
    public let timestamp: String?
}

public struct APIErrorInfo: Decodable, Sendable, Equatable {
    public let retryAfterSeconds: Int?
    public let remainingAttempts: Int?
    public let validationErrors: [APIFieldValidationError]

    private enum CodingKeys: String, CodingKey {
        case retryAfterSeconds
        case remainingAttempts
        case validationErrors = "errors"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        retryAfterSeconds = Self.decodeInteger(
            forKey: .retryAfterSeconds,
            from: container
        )
        remainingAttempts = Self.decodeInteger(
            forKey: .remainingAttempts,
            from: container
        )
        validationErrors = try container.decodeIfPresent(
            [APIFieldValidationError].self,
            forKey: .validationErrors
        ) ?? []
    }

    private static func decodeInteger(
        forKey key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>
    ) -> Int? {
        if let value = try? container.decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return Int(value)
        }
        return nil
    }
}

public struct APIFieldValidationError: Decodable, Sendable, Equatable {
    public let field: String
    public let message: String
}


public enum APIErrorCode: RawRepresentable, Decodable, Sendable, Equatable {

    case otpRateLimitExceeded
    case validationError

    case invalidTimezone
    case onboardingAlreadyCompleted
    case otpInvalidCode
    case otpExpiredOrNotFound
    case otpLocked
    case refreshTokenInvalid
    case refreshTokenExpired
    case refreshTokenReuseDetected

    case goalNotFound
    case taskNotFound
    case invalidOperation
    case duplicateTempId
    case unknownTempId
    case taskCyclicDependency
    case unknown(String)

    case userNotFound
    case invalidSleepSchedule
    case insufficientPoints

    public typealias RawValue = String

    public init(rawValue: String) {
        switch rawValue {
        case "OTP_RATE_LIMIT_EXCEEDED":       self = .otpRateLimitExceeded
        case "VALIDATION_ERROR":              self = .validationError
        case "INVALID_TIMEZONE":              self = .invalidTimezone
        case "ONBOARDING_ALREADY_COMPLETED":  self = .onboardingAlreadyCompleted
        case "OTP_INVALID_CODE":              self = .otpInvalidCode
        case "OTP_EXPIRED_OR_NOT_FOUND":      self = .otpExpiredOrNotFound
        case "OTP_LOCKED":                    self = .otpLocked
        case "REFRESH_TOKEN_INVALID":         self = .refreshTokenInvalid
        case "REFRESH_TOKEN_EXPIRED":         self = .refreshTokenExpired
        case "REFRESH_TOKEN_REUSE_DETECTED":  self = .refreshTokenReuseDetected
        case "GOAL_NOT_FOUND":                self = .goalNotFound
        case "TASK_NOT_FOUND":                self = .taskNotFound
        case "INVALID_OPERATION":             self = .invalidOperation
        case "DUPLICATE_TEMP_ID":             self = .duplicateTempId
        case "UNKNOWN_TEMP_ID":               self = .unknownTempId
        case "TASK_CYCLIC_DEPENDENCY":        self = .taskCyclicDependency
        case "USER_NOT_FOUND":                self = .userNotFound
        case "INVALID_SLEEP_SCHEDULE":        self = .invalidSleepSchedule
        case "INSUFFICIENT_POINTS":           self = .insufficientPoints
        default:                              self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .otpRateLimitExceeded:          return "OTP_RATE_LIMIT_EXCEEDED"
        case .validationError:               return "VALIDATION_ERROR"
        case .invalidTimezone:               return "INVALID_TIMEZONE"
        case .onboardingAlreadyCompleted:    return "ONBOARDING_ALREADY_COMPLETED"
        case .otpInvalidCode:                return "OTP_INVALID_CODE"
        case .otpExpiredOrNotFound:          return "OTP_EXPIRED_OR_NOT_FOUND"
        case .otpLocked:                     return "OTP_LOCKED"
        case .refreshTokenInvalid:           return "REFRESH_TOKEN_INVALID"
        case .refreshTokenExpired:           return "REFRESH_TOKEN_EXPIRED"
        case .refreshTokenReuseDetected:     return "REFRESH_TOKEN_REUSE_DETECTED"
        case .goalNotFound:                  return "GOAL_NOT_FOUND"
        case .taskNotFound:                  return "TASK_NOT_FOUND"
        case .invalidOperation:              return "INVALID_OPERATION"
        case .duplicateTempId:               return "DUPLICATE_TEMP_ID"
        case .unknownTempId:                 return "UNKNOWN_TEMP_ID"
        case .taskCyclicDependency:          return "TASK_CYCLIC_DEPENDENCY"
        case .userNotFound:                  return "USER_NOT_FOUND"
        case .invalidSleepSchedule:          return "INVALID_SLEEP_SCHEDULE"
        case .insufficientPoints:            return "INSUFFICIENT_POINTS"
        case .unknown(let code):             return code
        }
    }
}


public struct EmptyResponse: Decodable, Sendable {
    public init() {}
    public init(from decoder: any Decoder) throws {}
}
