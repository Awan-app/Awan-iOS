//
//  CreateAITaskRequest.swift
//  Domain
//

import Foundation

public struct CreateAITaskRequest: Hashable, Sendable {
    public let title: String
    public let description: String?

    public init(
        title: String,
        description: String? = nil
    ) {
        self.title = title
        self.description = description
    }
}
