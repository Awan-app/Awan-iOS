//
//  UpdateProfilePartialRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateProfilePartialRequestDTO: Encodable, Sendable {
    public let firstName: String?
    public let lastName: String?
    public let birthDate: String?
    public let timezone: String?
    public let preferredSessionDuration: Int?
    public let bufferBetweenSessions: Int?

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        birthDate: String? = nil,
        timezone: String? = nil,
        preferredSessionDuration: Int? = nil,
        bufferBetweenSessions: Int? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.timezone = timezone
        self.preferredSessionDuration = preferredSessionDuration
        self.bufferBetweenSessions = bufferBetweenSessions
    }
}
