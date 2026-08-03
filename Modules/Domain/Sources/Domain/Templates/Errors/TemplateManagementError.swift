import Foundation

public enum TemplateManagementError: Error, Equatable, Sendable {
    case authenticationFailed
    case validationFailed(String)
    case templateNameRequired
    case templateWeekdayRequired
    case overrideNameRequired
    case overrideDateInPast
    case overrideDateAlreadyExists
    case dayAlreadyAssigned
    case zoneOverlap
    case invalidZoneTimeRange
    case templateNotFound
    case overrideNotFound
    case networkFailure
    case invalidResponse
    case server(String)
}
