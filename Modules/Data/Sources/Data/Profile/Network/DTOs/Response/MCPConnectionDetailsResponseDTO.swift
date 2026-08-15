//
//  MCPConnectionDetailsResponseDTO.swift
//  Data
//

import Foundation

public struct MCPConnectionDetailsResponseDTO: Decodable, Sendable {
    public let mcpUrl: String
    public let clientId: String
}
