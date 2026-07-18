//
//  AuthRepository.swift
//  Domain
//
//  Created by Awan on 18/07/2026.
//

import Foundation

public protocol AuthRepository: Sendable {
    func requestOTP(email: String) async throws -> OTPRequestResult
}
