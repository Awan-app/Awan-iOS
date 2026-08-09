//
//  GamificationError.swift
//  Domain
//

import Foundation

public enum GamificationError: Error, Equatable, Sendable {
    case insufficientPoints
    case itemNotFound
    case unknown(message: String)
}
