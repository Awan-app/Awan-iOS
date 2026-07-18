//
//  RequestOTPUseCase.swift
//  Domain
//
//  Created by Awan on 18/07/2026.
//

import Foundation

public protocol RequestOTPUseCase: Sendable {
    func execute(email: String) async throws -> OTPRequestResult
}

public struct DefaultRequestOTPUseCase: RequestOTPUseCase {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws -> OTPRequestResult {
        return try await repository.requestOTP(email: email)
    }
}
