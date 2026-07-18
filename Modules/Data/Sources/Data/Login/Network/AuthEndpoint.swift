//
//  AuthEndpoint.swift
//  Data
//
//  Created by Awan on 18/07/2026.
//

import Foundation
import AwaNetwork

enum AuthEndpoint: APIEndpoint {
    case requestOTP(email: String)
    case verifyOTP(email: String, code: String, deviceId: String)
    case refreshToken(token: String, deviceId: String)
    case logout(deviceId: String)

    var baseURL: String {
        return "http://192.168.1.10:8080/api/v1/auth" // Replace with actual base URL config later
    }

    var path: String {
        switch self {
        case .requestOTP:
            return "/otp/request"
        case .verifyOTP:
            return "/otp/verify"
        case .refreshToken:
            return "/refresh"
        case .logout:
            return "/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .requestOTP, .verifyOTP, .refreshToken, .logout:
            return .post
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .requestOTP(let email):
            return OTPRequestRequestDTO(email: email)
        case .verifyOTP(let email, let code, let deviceId):
            return OTPVerifyRequestDTO(email: email, code: code, deviceId: deviceId)
        case .refreshToken(let token, let deviceId):
            return RefreshTokenRequestDTO(refreshToken: token, deviceId: deviceId)
        case .logout(let deviceId):
            return LogoutRequestDTO(deviceId: deviceId)
        }
    }

    var queryParameters: [String: String]? {
        return nil
    }
}
