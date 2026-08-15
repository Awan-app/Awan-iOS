//
//  MCPConnectionDetails.swift
//  Domain
//

import Foundation

public struct MCPConnectionDetails: Equatable, Sendable {
    public let mcpUrl: String
    public let clientId: String

    public init(mcpUrl: String, clientId: String) {
        self.mcpUrl = mcpUrl
        self.clientId = clientId
    }
}
