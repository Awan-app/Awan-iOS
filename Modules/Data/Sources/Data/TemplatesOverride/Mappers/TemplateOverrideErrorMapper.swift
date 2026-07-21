//
//  File.swift
//  Data
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Foundation
import AwaNetwork

public enum TemplateOverrideDataError: Error, Equatable, Sendable {
    case authenticationFailed
    case validationFailed([TemplateOverrideFieldValidationError])
    case notFound
    case invalidZoneTimeRange
    case networkFailure
    case invalidResponse
    case server(message: String)
}

public struct TemplateOverrideFieldValidationError: Equatable, Sendable {
    public let field: String
    public let message: String
}

public enum TemplateOverrideErrorMapper {
    public static func map(_ error: any Error) -> TemplateOverrideDataError {
        if let dataError = error as? TemplateOverrideDataError {
            return dataError
        }
        guard let networkError = error as? NetworkError else {
            return .server(message: error.localizedDescription)
        }
        return map(networkError)
    }

    private static func map(_ error: NetworkError) -> TemplateOverrideDataError {
        switch error {
        case .httpError(let statusCode, let apiError):
            if statusCode == 401 {
                return .authenticationFailed
            }
            
            guard let apiError else {
                return .server(message: error.localizedDescription)
            }

            if apiError.errorCode == .validationError {
                let fieldErrors = apiError.info?.validationErrors.map {
                    TemplateOverrideFieldValidationError(
                        field: $0.field,
                        message: $0.message
                    )
                } ?? []
                return .validationFailed(fieldErrors)
            }
            
            if apiError.errorCode == .templateOverrideNotFound {
                return .notFound
            }
            
            if statusCode == 400 && apiError.errorCode.rawValue == "INVALID_ZONE_TIME_RANGE" {
                return .invalidZoneTimeRange
            }
            
            return .server(message: apiError.message)
            
        case .underlying:
            return .networkFailure
        case .decodingFailed, .noContent:
            return .invalidResponse
        case .invalidURL, .encodingFailed:
            return .server(message: error.localizedDescription)
        }
    }
}
