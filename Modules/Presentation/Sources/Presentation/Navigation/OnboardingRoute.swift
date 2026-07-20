//
//  OnboardingRoute.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Foundation

public enum OnboardingRoute: Hashable, Identifiable, Sendable {
    case yourName
    case wakeSleep
    case suggestedZones
    case taskLength
    case taskSimulation
    case addRealTask
    case notification

    public var id: Self { self }
}
