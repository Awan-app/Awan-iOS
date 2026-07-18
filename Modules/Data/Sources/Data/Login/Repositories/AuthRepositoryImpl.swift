//
//  DefaultAuthRepository.swift
//  Data
//
//  Created by Awan on 18/07/2026.
//

import Foundation
import Domain
import AwaNetwork

public final class AuthRepositoryImpl: AuthRepository {
    private let remoteDataSource: AuthDataSource

    public init(remoteDataSource: AuthDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func requestOTP(email: String) async throws -> OTPRequestResult {
        do {
            let response = try await remoteDataSource.requestOTP(email: email)
            return response.toDomain()
        } catch let error as NetworkError {
            throw mapNetworkErrorToAuthError(error)
        } catch {
         
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }
    
    public func verifyOTP(email: String, code: String, deviceId: String) async throws -> VerifyOTPResult {
        do {
            let response = try await remoteDataSource.verifyOTP(email: email, code: code, deviceId: deviceId)
            
            if let accessData = response.accessToken.data(using: .utf8),
               let refreshData = response.refreshToken.data(using: .utf8) {
                try KeychainHelper.shared.save(accessData, service: "Awan.AccessToken", account: response.user.id)
                try KeychainHelper.shared.save(refreshData, service: "Awan.RefreshToken", account: response.user.id)
                
                print("--- DEBUG: RECEIVED TOKENS ---")
                print("Access Token: \(response.accessToken)")
                print("Refresh Token: \(response.refreshToken)")
                print("------------------------------")
            }
            
            return response.toDomain()
        } catch let error as NetworkError {
            throw mapNetworkErrorToAuthError(error)
        } catch let error as KeychainError {
            throw AuthError.unknown(message: "Failed to securely store session: \(error)")
        } catch {
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }
    
    private func mapNetworkErrorToAuthError(_ error: NetworkError) -> AuthError {
        switch error {
        case .httpError(_, let apiError):
            guard let apiError = apiError else { return .networkFailure }
            
            switch apiError.errorCode {
            case .otpRateLimitExceeded:
                var retryAfter = 60
                if case .int(let seconds) = apiError.info?["retryAfterSeconds"] {
                    retryAfter = seconds
                } else if case .double(let seconds) = apiError.info?["retryAfterSeconds"] {
                    retryAfter = Int(seconds)
                }
                return .rateLimited(retryAfterSeconds: retryAfter)
                
            case .validationError:
                return .invalidEmail
                
            case .otpInvalidCode:
                var attempts = 0
                if case .int(let remaining) = apiError.info?["remainingAttempts"] {
                    attempts = remaining
                }
                return .invalidCode(remainingAttempts: attempts)
                
            case .otpExpiredOrNotFound:
                return .expiredOrNotFound
                
            case .otpLocked:
                return .locked
                
            default:
                return .unknown(message: apiError.message)
            }
            
        case .underlying:
            return .networkFailure
            
        case .decodingFailed, .encodingFailed:
            return .unknown(message: "Data processing failed.")
            
        case .invalidURL, .noContent:
            return .unknown(message: "Invalid request.")
        }
    }
}
