//
//  GamificationError.swift
//  Domain
//

import Foundation

public enum GamificationError: Error, Equatable, Sendable {
    case insufficientPoints
    case itemNotFound
    case itemNotOwned
    case unknown(message: String)
    case alreadyClaimed
    case authenticationFailed
    case userNotFound
    case invalidWheelConfiguration
    case typeMismatch
    case invalidActivityRange
    case invalidActivityDate(String)
    case unavailable(String)
}
