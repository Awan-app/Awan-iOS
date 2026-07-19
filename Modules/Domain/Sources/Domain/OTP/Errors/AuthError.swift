//
//  AuthError.swift
//  Domain
//
//  Created by Awan on 18/07/2026.
//

import Foundation

public enum AuthError: Error, Equatable, Sendable {
    case invalidEmail
    case rateLimited(retryAfterSeconds: Int)
    case invalidCode(remainingAttempts: Int)
    case expiredOrNotFound
    case locked
    case networkFailure
    case unknown(message: String)
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .rateLimited(let seconds):
            return "Too many requests. Please try again in \(seconds) seconds."
        case .invalidCode(let remaining):
            return "Invalid OTP code. \(remaining) attempts remaining."
        case .expiredOrNotFound:
            return "OTP expired or not found. Please request a new one."
        case .locked:
            return "Too many failed attempts. Account locked. Please request a new OTP."
        case .networkFailure:
            return "A network error occurred. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}
