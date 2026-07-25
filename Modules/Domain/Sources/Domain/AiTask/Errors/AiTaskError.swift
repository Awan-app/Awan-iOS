//
//  AiTaskError.swift
//  Domain
//

import Foundation

public enum AiTaskError: Error, Equatable, Sendable {
    /// The title field is missing or blank (HTTP 422 VALIDATION_ERROR).
    case validationError(message: String)
    /// The AI service is temporarily unavailable (HTTP 503 AI_UNAVAILABLE).
    case aiUnavailable
    /// An unexpected network or server failure.
    case networkFailure
    case unknown(message: String)
}

extension AiTaskError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .validationError(let message):
            return message
        case .aiUnavailable:
            return "The AI service is temporarily unavailable. Please try again later."
        case .networkFailure:
            return "A network error occurred. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}
