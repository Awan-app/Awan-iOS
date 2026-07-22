//
//  File.swift
//  Domain
//
//  Created by Me3bed on 22/07/2026.
//

import Foundation

public struct ZoneDraft: Sendable {
    public let id: UUID
    public let name: String
    public let colorRed: Double
    public let colorGreen: Double
    public let colorBlue: Double
    public let startTime: String
    public let endTime: String   

    public init(
        id: UUID,
        name: String,
        colorRed: Double,
        colorGreen: Double,
        colorBlue: Double,
        startTime: String,
        endTime: String
    ) {
        self.id = id
        self.name = name
        self.colorRed = colorRed
        self.colorGreen = colorGreen
        self.colorBlue = colorBlue
        self.startTime = startTime
        self.endTime = endTime
    }
}
