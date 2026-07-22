//
//  SuggestedZone.swift
//  Presentation
//
//  Created by Me3bed on 20/07/2026.
//
import Foundation
import Domain

public struct SuggestedZone: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var startTime: String
    public var endTime: String
    public var colorRed: Double
    public var colorGreen: Double
    public var colorBlue: Double

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

extension SuggestedZone {
    var asDraft: ZoneDraft {
        ZoneDraft(
            id: id,
            name: name,
            colorRed: colorRed,
            colorGreen: colorGreen,
            colorBlue: colorBlue,
            startTime: startTime,
            endTime: endTime
        )
    }
}

extension ZoneDraft {
    var asSuggestedZone: SuggestedZone {
        SuggestedZone(
            id: id,
            name: name,
            startTime: startTime,
            endTime: endTime,
            colorRed: colorRed,
            colorGreen: colorGreen,
            colorBlue: colorBlue
        )
    }
}
