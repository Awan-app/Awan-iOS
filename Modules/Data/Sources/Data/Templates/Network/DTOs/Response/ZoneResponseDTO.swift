//
//  ZoneResponseDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct ZoneResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String
    public let startTime: String
    public let endTime: String
    public let color: String?
    public let templateId: UUID?
    public let templateOverrideId: UUID?

    public init(
        id: UUID,
        name: String,
        startTime: String,
        endTime: String,
        color: String?,
        templateId: UUID?,
        templateOverrideId: UUID?
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.templateId = templateId
        self.templateOverrideId = templateOverrideId
    }
}
