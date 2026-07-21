//
//  UpdateZoneRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateZoneRequestDTO: Encodable, Sendable {
    public let name: String
    public let startTime: String
    public let endTime: String
    public let color: String?

    public init(
        name: String,
        startTime: String,
        endTime: String,
        color: String? = nil
    ) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
    }
}
