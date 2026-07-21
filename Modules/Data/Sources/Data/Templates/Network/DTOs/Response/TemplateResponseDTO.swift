//
//  TemplateResponseDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct TemplateResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String
    public let daysOfWeek: [String]
    public let zones: [ZoneResponseDTO]

    public init(
        id: UUID,
        name: String,
        daysOfWeek: [String],
        zones: [ZoneResponseDTO]
    ) {
        self.id = id
        self.name = name
        self.daysOfWeek = daysOfWeek
        self.zones = zones
    }
}
