import AwaNetwork
import Domain
import Foundation

enum TemplateManagementErrorMapper {
    static func map(_ error: any Error, overrideOperation: Bool = false) -> TemplateManagementError {
        if let error = error as? TemplateManagementError {
            return error
        }
        guard let networkError = error as? NetworkError else {
            return .server(error.localizedDescription)
        }

        switch networkError {
        case .httpError(let statusCode, let apiError):
            guard let apiError else {
                return .server(networkError.localizedDescription)
            }
            switch apiError.errorCode {
            case .dayAlreadyAssigned:
                return .dayAlreadyAssigned
            case .zoneOverlap:
                return .zoneOverlap
            case .invalidZoneTimeRange:
                return .invalidZoneTimeRange
            case .templateNotFound:
                return .templateNotFound
            case .templateOverrideNotFound:
                return .overrideNotFound
            case .validationError:
                let details = apiError.info?.validationErrors
                    .map(\.message)
                    .joined(separator: "\n")
                return .validationFailed(
                    details.flatMap { $0.isEmpty ? nil : $0 } ?? apiError.message
                )
            default:
                if statusCode == 401 { return .authenticationFailed }
                if statusCode == 404 {
                    return overrideOperation ? .overrideNotFound : .templateNotFound
                }
                return .server(apiError.message)
            }
        case .underlying:
            return .networkFailure
        case .decodingFailed, .noContent:
            return .invalidResponse
        case .invalidURL, .encodingFailed:
            return .server(networkError.localizedDescription)
        }
    }
}
