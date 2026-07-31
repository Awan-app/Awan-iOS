//
//  CreateAITaskRequestDTO.swift
//  Data
//

import Foundation

public struct CreateAITaskRequestDTO: Encodable, Sendable {
    public let text: String

    public init(
        text: String,
    ) {
        self.text = text
    }
}
