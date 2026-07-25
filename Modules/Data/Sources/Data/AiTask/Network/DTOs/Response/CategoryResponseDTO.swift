//
//  CategoryResponseDTO.swift
//  Data
//

import Foundation

public struct CategoryResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String

    public init(
        id: UUID,
        name: String
    ) {
        self.id = id
        self.name = name
    }
}
