//
//  ZoneErrorMapper.swift
//  Data
//

import Foundation
import AwaNetwork

public enum ZoneDataError: Error, Equatable, Sendable {
    case authenticationFailed
    case validationFailed([ZoneFieldValidationError])
    case notFound
    case networkFailure
    case invalidResponse
    case server(message: String)
}

public struct ZoneFieldValidationError: Equatable, Sendable {
    public let field: String
    public let message: String
}

public enum ZoneErrorMapper {
    public static func map(_ error: any Error) -> ZoneDataError {
        if let dataError = error as? ZoneDataError {
            return dataError
        }
        guard let networkError = error as? NetworkError else {
            return .server(message: error.localizedDescription)
        }
        return map(networkError)
    }

    private static func map(_ error: NetworkError) -> ZoneDataError {
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
                    ZoneFieldValidationError(
                        field: $0.field,
                        message: $0.message
                    )
                } ?? []
                return .validationFailed(fieldErrors)
            }
            
            if apiError.errorCode == .zoneNotFound {
                return .notFound
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
