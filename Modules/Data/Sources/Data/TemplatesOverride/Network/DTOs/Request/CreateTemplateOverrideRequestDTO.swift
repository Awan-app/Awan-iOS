//
//  CreateTemplateOverrideRequestDTO.swift
//  Data
//

import Foundation

public struct CreateTemplateOverrideRequestDTO: Encodable, Sendable {
    public let name: String?
    public let dateOfDay: String
    public let zones: [AddZoneRequestDTO]?
    
    public init(name: String?, dateOfDay: String, zones: [AddZoneRequestDTO]?) {
        self.name = name
        self.dateOfDay = dateOfDay
        self.zones = zones
    }
}
