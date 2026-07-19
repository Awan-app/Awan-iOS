import Foundation

public struct AuthSessionUser: Codable, Sendable, Equatable {
    public let id: String
    public let email: String
    public let isNew: Bool

    public init(id: String, email: String, isNew: Bool) {
        self.id = id
        self.email = email
        self.isNew = isNew
    }
}

public struct AuthSession: Codable, Sendable, Equatable {
    public let accessToken: String
    public let refreshToken: String
    public let accessTokenExpiresAt: Date
    public let user: AuthSessionUser

    public init(
        accessToken: String,
        refreshToken: String,
        accessTokenExpiresAt: Date,
        user: AuthSessionUser
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresAt = accessTokenExpiresAt
        self.user = user
    }
}
