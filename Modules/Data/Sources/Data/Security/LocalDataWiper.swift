import Foundation

public protocol LocalDataWiper: Sendable {
    func wipeAllData() async throws
}
