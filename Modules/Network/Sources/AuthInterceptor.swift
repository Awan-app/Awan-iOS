import Alamofire
import Foundation

extension AuthSession: AuthenticationCredential {
    public var requiresRefresh: Bool {
        accessTokenExpiresAt <= Date().addingTimeInterval(30)
    }
}

final class AuthSessionAuthenticator: Authenticator {
    typealias Credential = AuthSession

    func apply(_ credential: AuthSession, to urlRequest: inout URLRequest) {
        urlRequest.setValue(
            "Bearer \(credential.accessToken)",
            forHTTPHeaderField: "Authorization"
        )
    }

    func refresh(
        _ credential: AuthSession,
        for session: Session,
        completion: @escaping @Sendable (Result<AuthSession, any Error>) -> Void
    ) {
        do {
            let request = try makeRefreshRequest(credential: credential)
            AF.request(request)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        self.completeRefresh(
                            data: data,
                            currentSession: credential,
                            completion: completion
                        )
                    case .failure(let error):
                        self.failRefresh(
                            response: response.response,
                            data: response.data,
                            error: error,
                            completion: completion
                        )
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }

    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: any Error
    ) -> Bool {
        response.statusCode == 401
    }

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: AuthSession
    ) -> Bool {
        urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer \(credential.accessToken)"
    }

    private func makeRefreshRequest(credential: AuthSession) throws -> URLRequest {
        guard let url = URL(string: NetworkConfiguration.authBaseURL + "/refresh") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            RefreshTokenRequest(
                refreshToken: credential.refreshToken,
                deviceId: try AuthSessionStore.deviceId()
            )
        )
        return request
    }

    private func completeRefresh(
        data: Data,
        currentSession: AuthSession,
        completion: @escaping @Sendable (Result<AuthSession, any Error>) -> Void
    ) {
        do {
            let response = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            let session = AuthSession(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(
                    TimeInterval(max(0, response.accessTokenExpiresIn))
                ),
                user: currentSession.user
            )
            try AuthSessionStore.saveAfterRefresh(session)
            completion(.success(session))
        } catch {
            completion(.failure(NetworkError.decodingFailed(error)))
        }
    }

    private func failRefresh(
        response: HTTPURLResponse?,
        data: Data?,
        error: AFError,
        completion: @escaping @Sendable (Result<AuthSession, any Error>) -> Void
    ) {
        let networkError: NetworkError
        if let statusCode = response?.statusCode {
            let apiError = data.flatMap {
                try? JSONDecoder().decode(APIErrorResponse.self, from: $0)
            }
            networkError = .httpError(statusCode: statusCode, apiError: apiError)
        } else {
            networkError = .underlying(error)
        }

        let invalidatesSession = networkError.invalidatesRefreshToken
        if invalidatesSession {
            AuthSessionStore.clearAfterInvalidRefresh()
        }
        completion(.failure(networkError))

        if invalidatesSession {
            NetworkClient.shared.setSession(nil)
        }
    }
}

private struct RefreshTokenRequest: Encodable {
    let refreshToken: String
    let deviceId: String
}

private struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let accessTokenExpiresIn: Int
    let refreshToken: String
}

private extension NetworkError {
    var invalidatesRefreshToken: Bool {
        guard case .httpError(let statusCode, let apiError) = self,
              statusCode == 401,
              let errorCode = apiError?.errorCode else {
            return false
        }

        switch errorCode {
        case .refreshTokenInvalid, .refreshTokenExpired, .refreshTokenReuseDetected:
            return true
        default:
            return false
        }
    }
}
