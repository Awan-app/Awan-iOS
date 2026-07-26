//
//  TaskCategory.swift
//  Domain
//

import Foundation

public struct TaskCategory: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String

    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
