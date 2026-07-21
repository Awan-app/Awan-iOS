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
    case notification

    public var id: Self { self }

    public var stepNumber: Int {
        switch self {
        case .yourName: return 1
        case .wakeSleep: return 2
        case .suggestedZones: return 3
        case .taskLength: return 4
        case .taskSimulation: return 5
        case .notification: return 6
        }
    }
}
