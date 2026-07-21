//
//  TaskWithSessionsResponseDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct TaskWithSessionsResponseDTO: Decodable, Sendable {
    public let task: TaskInfoResponseDTO
    public let sessions: [SessionResponseDTO]

    public init(task: TaskInfoResponseDTO, sessions: [SessionResponseDTO]) {
        self.task = task
        self.sessions = sessions
    }
}
