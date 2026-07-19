import Foundation
import SimpleKeychain

public enum AuthSessionStore {
    private static let storage = Storage()

    public static var session: AuthSession? {
        try? storage.loadSession()
    }

    public static var accessToken: String? {
        session?.accessToken
    }

    public static var refreshToken: String? {
        session?.refreshToken
    }

    public static func deviceId() throws -> String {
        try storage.deviceId()
    }

    public static func save(_ session: AuthSession) throws {
        try storage.saveSession(session)
        NetworkClient.shared.setSession(session)
    }

    public static func clear() throws {
        try storage.clearSession()
        NetworkClient.shared.setSession(nil)
    }

    public static func observeSession() -> AsyncStream<AuthSession?> {
        storage.observeSession()
    }

    static func saveAfterRefresh(_ session: AuthSession) throws {
        try storage.saveSession(session)
    }

    static func clearAfterInvalidRefresh() {
        try? storage.clearSession()
    }
}

private final class Storage: @unchecked Sendable {
    private enum Keys {
        static let service = "com.awan.auth.secure"
        static let session = "current-session"
        static let deviceId = "installation-device-id"
        static let installationMarker = "com.awan.auth.has-launched-before"
    }

    private let keychain = SimpleKeychain(
        service: Keys.service,
        accessibility: .afterFirstUnlockThisDeviceOnly
    )
    private let lock = NSLock()
    private var observers: [UUID: AsyncStream<AuthSession?>.Continuation] = [:]

    init() {
        resetAfterReinstallIfNeeded()
    }

    func loadSession() throws -> AuthSession? {
        guard try keychain.hasItem(forKey: Keys.session) else { return nil }
        let data = try keychain.data(forKey: Keys.session)

        do {
            return try JSONDecoder().decode(AuthSession.self, from: data)
        } catch {
            try? keychain.deleteItem(forKey: Keys.session)
            return nil
        }
    }

    func saveSession(_ session: AuthSession) throws {
        try keychain.set(try JSONEncoder().encode(session), forKey: Keys.session)
        publish(session)
    }

    func clearSession() throws {
        if try keychain.hasItem(forKey: Keys.session) {
            try keychain.deleteItem(forKey: Keys.session)
        }
        publish(nil)
    }

    func deviceId() throws -> String {
        if try keychain.hasItem(forKey: Keys.deviceId) {
            let value = try keychain.string(forKey: Keys.deviceId)
            if !value.isEmpty { return value }
            try keychain.deleteItem(forKey: Keys.deviceId)
        }

        let value = UUID().uuidString
        try keychain.set(value, forKey: Keys.deviceId)
        return value
    }

    func observeSession() -> AsyncStream<AuthSession?> {
        AsyncStream { continuation in
            let id = UUID()
            lock.withLock { observers[id] = continuation }
            continuation.yield(try? loadSession())
            continuation.onTermination = { [weak self] _ in
                _ = self?.lock.withLock {
                    self?.observers.removeValue(forKey: id)
                }
            }
        }
    }

    private func publish(_ session: AuthSession?) {
        lock.withLock { Array(observers.values) }
            .forEach { $0.yield(session) }
    }

    private func resetAfterReinstallIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: Keys.installationMarker) else { return }

        do {
            try keychain.deleteAll()
            defaults.set(true, forKey: Keys.installationMarker)
        } catch {
            // Keep the marker unset so cleanup is retried on the next launch.
        }
    }
}
