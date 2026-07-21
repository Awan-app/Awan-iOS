//
//  TemplateOverrideResponseDTO.swift
//  Data
//

import Foundation

public struct TemplateOverrideResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String?
    public let dateOfDay: String
    public let zones: [ZoneResponseDTO]
    
    public init(id: UUID, name: String?, dateOfDay: String, zones: [ZoneResponseDTO]) {
        self.id = id
        self.name = name
        self.dateOfDay = dateOfDay
        self.zones = zones
    }
}
