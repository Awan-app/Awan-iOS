//
//  UpdateTemplateRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct UpdateTemplateRequestDTO: Encodable, Sendable {
    public let name: String
    public let daysOfWeek: [String]

    public init(name: String, daysOfWeek: [String]) {
        self.name = name
        self.daysOfWeek = daysOfWeek
    }
}
