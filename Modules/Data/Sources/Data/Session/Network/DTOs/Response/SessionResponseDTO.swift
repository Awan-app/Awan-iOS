//
//  SessionResponseDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct SessionResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let start: String
    public let end: String
    public let status: String
    public let locked: Bool
    public let zoneId: UUID?

    public init(
        id: UUID,
        start: String,
        end: String,
        status: String,
        locked: Bool,
        zoneId: UUID?
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.status = status
        self.locked = locked
        self.zoneId = zoneId
    }
}
