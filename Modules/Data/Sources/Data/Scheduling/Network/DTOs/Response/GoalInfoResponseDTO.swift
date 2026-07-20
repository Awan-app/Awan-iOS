//
//  GoalInfoResponseDTO.swift
//  Data
//

import Foundation

public struct GoalInfoResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let status: String
    public let targetDate: String?
    public let createdAt: String
    public let inbox: Bool
    public let tasks: [TaskInfoResponseDTO]

    public init(
        id: UUID,
        title: String,
        description: String?,
        status: String,
        targetDate: String?,
        createdAt: String,
        inbox: Bool,
        tasks: [TaskInfoResponseDTO]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.inbox = inbox
        self.tasks = tasks
    }
}

public struct PagedGoalResponseDTO: Decodable, Sendable {
    public let content: [GoalInfoResponseDTO]
    public let totalElements: Int
    public let totalPages: Int
    public let number: Int
    public let size: Int
    public let first: Bool
    public let last: Bool

    public init(
        content: [GoalInfoResponseDTO],
        totalElements: Int,
        totalPages: Int,
        number: Int,
        size: Int,
        first: Bool,
        last: Bool
    ) {
        self.content = content
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.number = number
        self.size = size
        self.first = first
        self.last = last
    }
}
