//
//  CreateAITaskRequestDTO.swift
//  Data
//

import Foundation

public struct CreateAITaskRequestDTO: Encodable, Sendable {
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
