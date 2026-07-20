//
//  UpdateTimezoneRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateTimezoneRequestDTO: Encodable, Sendable {
    public let timezone: String

    public init(timezone: String) {
        self.timezone = timezone
    }
}
