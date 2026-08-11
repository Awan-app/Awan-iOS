//
//  AddZoneRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct AddZoneRequestDTO: Encodable, Sendable {
    public let name: String
    public let startTime: String
    public let endTime: String
    public let color: String?
    public let categoryId: UUID

    public init(
        name: String,
        startTime: String,
        endTime: String,
        color: String? = nil,
        categoryId: UUID
    ) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.categoryId = categoryId
    }
}
