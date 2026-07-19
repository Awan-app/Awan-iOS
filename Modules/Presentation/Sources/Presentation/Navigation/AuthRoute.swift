//
//  AuthRoute.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import Foundation

public struct OtpVerificationContext: Hashable, Sendable {
    public let email: String
    public let initialResendSeconds: Int

    public init(email: String, initialResendSeconds: Int) {
        self.email = email
        self.initialResendSeconds = initialResendSeconds
    }
}

public enum AuthRoute: Hashable, Identifiable, Sendable {
    case login
    case otpVerification(OtpVerificationContext)

    public var id: Self { self }
}
