//
//  SuggestedZone.swift
//  Presentation
//
//  Created by Me3bed on 20/07/2026.
//
import Foundation

public struct SuggestedZone: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let startTime: String
    public let endTime: String
    public let colorRed: Double
    public let colorGreen: Double
    public let colorBlue: Double

    public init(id: UUID, name: String, startTime: String, endTime: String, colorRed: Double, colorGreen: Double, colorBlue: Double) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.colorRed = colorRed
        self.colorGreen = colorGreen
        self.colorBlue = colorBlue
    }
}
