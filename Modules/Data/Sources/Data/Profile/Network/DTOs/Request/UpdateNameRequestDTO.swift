//
//  UpdateNameRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateNameRequestDTO: Encodable, Sendable {
    public let firstName: String
    public let lastName: String

    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
