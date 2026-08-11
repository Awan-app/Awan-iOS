//
//  CreateAITaskRequest.swift
//  Domain
//

import Foundation

public struct CreateAITaskRequest: Hashable, Sendable {
    public let text: String

    public init(
        text: String
    ) {
        self.text = text
    }
}
