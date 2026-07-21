//
//  UpdateTemplateOverrideRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateTemplateOverrideRequestDTO: Encodable, Sendable {
    public let name: String?
    public let dateOfDay: String
    
    public init(name: String?, dateOfDay: String) {
        self.name = name
        self.dateOfDay = dateOfDay
    }
}
