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
    public let taskID: UUID

    private enum CodingKeys: String, CodingKey {
        case id
        case start
        case end
        case status
        case locked
        case zoneId
        case taskID = "taskId"
    }

    public init(
        id: UUID,
        start: String,
        end: String,
        status: String,
        locked: Bool,
        zoneId: UUID?,
        taskID: UUID
    ) {
        self.id = id
        self.start = start
        self.end = end
        self.status = status
        self.locked = locked
        self.zoneId = zoneId
        self.taskID = taskID
    }
}
