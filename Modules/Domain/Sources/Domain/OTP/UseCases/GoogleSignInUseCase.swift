//
//  GoogleSignInUseCase.swift
//  Domain
//
//  Created by Agent on 18/07/2026.
//

import Foundation

public protocol GoogleSignInUseCase: Sendable {
    func execute(idToken: String, accessToken: String) async throws -> VerifyOTPResult
}

public struct DefaultGoogleSignInUseCase: GoogleSignInUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(idToken: String, accessToken: String) async throws -> VerifyOTPResult {
        return try await authRepository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}
