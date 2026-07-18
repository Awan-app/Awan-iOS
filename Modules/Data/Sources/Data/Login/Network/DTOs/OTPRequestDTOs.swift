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
public struct OTPVerifyRequestDTO: Encodable, Sendable {
    public let email: String
    public let code: String
    public let deviceId: String
    
    public init(email: String, code: String, deviceId: String) {
        self.email = email
        self.code = code
        self.deviceId = deviceId
    }
}

public struct OTPVerifyUserDTO: Decodable, Sendable {
    public let id: String
    public let email: String
    public let isNew: Bool
}

public struct OTPVerifyResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let accessTokenExpiresIn: Int
    public let refreshToken: String
    public let user: OTPVerifyUserDTO
    
    public func toDomain() -> VerifyOTPResult {
        return VerifyOTPResult(
            user: UserEntity(id: user.id, email: user.email, isNew: user.isNew)
        )
    }
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
