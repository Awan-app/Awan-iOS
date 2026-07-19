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
    case logout(deviceId: String)

    var baseURL: String {
        NetworkConfiguration.authBaseURL
    }

    var path: String {
        switch self {
        case .requestOTP:
            return "/otp/request"
        case .verifyOTP:
            return "/otp/verify"
        case .logout:
            return "/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .requestOTP, .verifyOTP, .logout:
            return .post
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .requestOTP(let email):
            return OTPRequestRequestDTO(email: email)
        case .verifyOTP(let email, let code, let deviceId):
            return OTPVerifyRequestDTO(email: email, code: code, deviceId: deviceId)
        case .logout(let deviceId):
            return LogoutRequestDTO(deviceId: deviceId)
        }
    }

    var queryParameters: [String: String]? {
        return nil
    }

    var requiresAuthentication: Bool {
        if case .logout = self {
            return true
        }
        return false
    }
}
