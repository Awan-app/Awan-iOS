import AwaNetwork
import Domain
import Foundation
import FirebaseAuth

public final class AuthRepositoryImpl: AuthRepository, @unchecked Sendable {
    private let remoteDataSource: AuthDataSource
    private let sessionDataSource: AuthSessionDataSource
    private let localDataWiper: LocalDataWiper

    public init(
        remoteDataSource: AuthDataSource,
        sessionDataSource: AuthSessionDataSource,
        localDataWiper: LocalDataWiper
    ) {
        self.remoteDataSource = remoteDataSource
        self.sessionDataSource = sessionDataSource
        self.localDataWiper = localDataWiper
    }

    public func requestOTP(email: String) async throws -> OTPRequestResult {
        do {
            return try await remoteDataSource.requestOTP(email: email).toDomain()
        } catch let error as NetworkError {
            throw mapNetworkErrorToAuthError(error)
        } catch {
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }

    public func verifyOTP(email: String, code: String) async throws -> VerifyOTPResult {
        do {
            let deviceId = try sessionDataSource.deviceId()
            let response = try await remoteDataSource.verifyOTP(
                email: email,
                code: code,
                deviceId: deviceId
            )
            let session = AuthSession(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(
                    TimeInterval(max(0, response.accessTokenExpiresIn))
                ),
                user: AuthSessionUser(
                    id: response.user.id,
                    email: response.user.email,
                    isNew: response.user.isNew
                )
            )

            try sessionDataSource.save(session)
            return response.toDomain()
        } catch let error as NetworkError {
            throw mapNetworkErrorToAuthError(error)
        } catch {
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }

    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> VerifyOTPResult {
        do {
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)
            let firebaseToken = try await authResult.user.getIDToken()
            
            let deviceId = try sessionDataSource.deviceId()
            let response = try await remoteDataSource.firebaseSignIn(idToken: firebaseToken, deviceId: deviceId)
            
            let session = AuthSession(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(
                    TimeInterval(max(0, response.accessTokenExpiresIn))
                ),
                user: AuthSessionUser(
                    id: response.user.id,
                    email: response.user.email,
                    isNew: response.user.isNew
                )
            )

            try sessionDataSource.save(session)
            return response.toDomain()
        } catch let error as NetworkError {
            throw mapNetworkErrorToAuthError(error)
        } catch {
            throw AuthError.unknown(message: error.localizedDescription)
        }
    }

    public func observeAuthenticatedUser() -> AsyncStream<UserEntity?> {
        let users = sessionDataSource.observeSessionUser()

        return AsyncStream { continuation in
            let task = Task {
                for await user in users {
                    guard !Task.isCancelled else { break }
                    continuation.yield(user?.toDomain())
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func logout() async throws {
        let deviceId = try? sessionDataSource.deviceId()
        var remoteError: Error?

        if localSessionExists(), let deviceId {
            do {
                try await remoteDataSource.logout(deviceId: deviceId)
            } catch {
                remoteError = error
            }
        }

        do {
            try sessionDataSource.clear()
            try await localDataWiper.wipeAllData()
        } catch where remoteError == nil {
            throw AuthError.unknown(message: "Failed to securely clear local data: \(error)")
        } catch {
            // The remote error remains the primary result, but the in-memory credential is still cleared.
        }

        if let networkError = remoteError as? NetworkError {
            throw mapNetworkErrorToAuthError(networkError)
        }
        if let remoteError {
            throw AuthError.unknown(message: remoteError.localizedDescription)
        }
    }

    private func localSessionExists() -> Bool {
        sessionDataSource.hasSession
    }

    private func mapNetworkErrorToAuthError(_ error: NetworkError) -> AuthError {
        switch error {
        case .httpError(_, let apiError):
            guard let apiError else { return .networkFailure }

            switch apiError.errorCode {
            case .otpRateLimitExceeded:
                return .rateLimited(
                    retryAfterSeconds: apiError.info?.retryAfterSeconds ?? 60
                )
            case .validationError:
                return .invalidEmail
            case .otpInvalidCode:
                return .invalidCode(
                    remainingAttempts: apiError.info?.remainingAttempts ?? 0
                )
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

private extension AuthSessionUser {
    func toDomain() -> UserEntity {
        UserEntity(id: id, email: email, isNew: isNew)
    }
}
