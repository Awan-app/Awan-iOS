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
