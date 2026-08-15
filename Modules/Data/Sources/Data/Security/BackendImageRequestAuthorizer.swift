import AwaNetwork
import Foundation

public enum BackendImageRequestAuthorizer {
    public static func authorize(_ request: URLRequest) -> URLRequest {
        guard
            let requestURL = request.url,
            let backendURL = URL(string: NetworkConfiguration.backendBaseURL),
            requestURL.scheme?.caseInsensitiveCompare(backendURL.scheme ?? "") == .orderedSame,
            requestURL.host?.caseInsensitiveCompare(backendURL.host ?? "") == .orderedSame,
            requestURL.port == backendURL.port,
            let accessToken = AuthSessionStore.accessToken,
            !accessToken.isEmpty
        else {
            return request
        }

        var authorizedRequest = request
        authorizedRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        return authorizedRequest
    }
}
