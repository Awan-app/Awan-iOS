//
//  OTPRequestDTOs.swift
//  Data
//
//  Created by Awan on 18/07/2026.
//

import Foundation
import Domain

// MARK: - Request OTP
struct OTPRequestRequestDTO: Encodable {
    let email: String
}

public struct OTPRequestResponseDTO: Decodable, Sendable {
    public let expiresInSeconds: Int
    public let resendAvailableInSeconds: Int
    
    public init(expiresInSeconds: Int, resendAvailableInSeconds: Int) {
        self.expiresInSeconds = expiresInSeconds
        self.resendAvailableInSeconds = resendAvailableInSeconds
    }
    
    public func toDomain() -> OTPRequestResult {
        return OTPRequestResult(
            expiresInSeconds: expiresInSeconds,
            resendAvailableInSeconds: resendAvailableInSeconds
        )
    }
}

// MARK: - Verify OTP (Placeholders for compilation)
struct OTPVerifyRequestDTO: Encodable {
    let email: String
    let code: String
    let deviceId: String
}

struct OTPVerifyResponseDTO: Decodable {
    let accessToken: String
    let accessTokenExpiresIn: Int
    let refreshToken: String
    // user etc.
}

// MARK: - Refresh Token (Placeholders for compilation)
struct RefreshTokenRequestDTO: Encodable {
    let refreshToken: String
    let deviceId: String
}

struct RefreshTokenResponseDTO: Decodable {
    let accessToken: String
    let accessTokenExpiresIn: Int
    let refreshToken: String
}

// MARK: - Logout (Placeholders for compilation)
struct LogoutRequestDTO: Encodable {
    let deviceId: String
}
