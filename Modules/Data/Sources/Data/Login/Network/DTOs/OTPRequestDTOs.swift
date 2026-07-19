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

// MARK: - Verify OTP
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

// MARK: - Logout
struct LogoutRequestDTO: Encodable, Sendable {
    let deviceId: String
}
