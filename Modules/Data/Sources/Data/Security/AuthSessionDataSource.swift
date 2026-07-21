import AwaNetwork
import Foundation

public protocol AuthSessionDataSource: Sendable {
    var hasSession: Bool { get }

    func deviceId() throws -> String
    func save(_ session: AuthSession) throws
    func markOnboardingCompleted() throws
    func clear() throws
    func observeSessionUser() -> AsyncStream<AuthSessionUser?>
}

public final class LocalAuthSessionDataSource: AuthSessionDataSource {
    public init() {}

    public var hasSession: Bool {
        AuthSessionStore.session != nil
    }

    public func deviceId() throws -> String {
        try AuthSessionStore.deviceId()
    }

    public func save(_ session: AuthSession) throws {
        try AuthSessionStore.save(session)
    }

    public func markOnboardingCompleted() throws {
        guard let session = AuthSessionStore.session else {
            throw AuthSessionDataSourceError.missingSession
        }

        try save(
            AuthSession(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                accessTokenExpiresAt: session.accessTokenExpiresAt,
                user: AuthSessionUser(
                    id: session.user.id,
                    email: session.user.email,
                    isNew: false
                )
            )
        )
    }

    public func clear() throws {
        try AuthSessionStore.clear()
    }

    public func observeSessionUser() -> AsyncStream<AuthSessionUser?> {
        let sessions = AuthSessionStore.observeSession()

        return AsyncStream { continuation in
            let task = Task {
                for await session in sessions {
                    guard !Task.isCancelled else { break }
                    continuation.yield(session?.user)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

private enum AuthSessionDataSourceError: Error {
    case missingSession
}
