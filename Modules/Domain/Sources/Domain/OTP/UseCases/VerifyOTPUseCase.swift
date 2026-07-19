//
//  VerifyOTPUseCase.swift
//  Domain
//

import Foundation

public struct VerifyOTPUseCase: Sendable {
    private let repository: AuthRepository

    public init(repository: AuthRepository) {
        self.repository = repository
    }

    public func execute(email: String, code: String) async throws -> VerifyOTPResult {
        return try await repository.verifyOTP(email: email, code: code)
    }
}
