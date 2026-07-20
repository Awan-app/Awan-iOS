//
//  UpdateSessionSettingsRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateSessionSettingsRequestDTO: Encodable, Sendable {
    public let preferredSessionDuration: Int
    public let bufferBetweenSessions: Int

    public init(preferredSessionDuration: Int, bufferBetweenSessions: Int) {
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
    }
}
