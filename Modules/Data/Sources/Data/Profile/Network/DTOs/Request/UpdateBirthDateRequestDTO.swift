//
//  UpdateBirthDateRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateBirthDateRequestDTO: Encodable, Sendable {
    public let birthDate: String

    public init(birthDate: String) {
        self.birthDate = birthDate
    }
}
