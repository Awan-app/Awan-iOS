//
//  File.swift
//  Data
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Foundation

public struct SessionResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let taskId: UUID
    public let zoneId: UUID?
    public let startTime: String
    public let endTime: String
    public let status: String
    public let blocking: Bool
    
    public init(
        id: UUID,
        taskId: UUID,
        zoneId: UUID?,
        startTime: String,
        endTime: String,
        status: String,
        blocking: Bool
    ) {
        self.id = id
        self.taskId = taskId
        self.zoneId = zoneId
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.blocking = blocking
    }
}
