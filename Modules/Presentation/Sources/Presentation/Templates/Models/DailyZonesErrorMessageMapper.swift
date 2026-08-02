import Common
import Domain
import Foundation

enum DailyZonesErrorMessageMapper {
    static func message(for error: any Error) -> String {
        switch error {
        case TemplateManagementError.authenticationFailed:
            L10n.Templates.authenticationError
        case TemplateManagementError.templateNameRequired,
             TemplateManagementError.templateWeekdayRequired:
            L10n.Templates.selectNameAndDay
        case TemplateManagementError.overrideNameRequired:
            L10n.Templates.overrideNameRequired
        case TemplateManagementError.overrideDateInPast:
            L10n.Templates.chooseFutureDate
        case TemplateManagementError.overrideDateAlreadyExists:
            L10n.Templates.duplicateOverride
        case TemplateManagementError.dayAlreadyAssigned:
            L10n.Templates.dayAlreadyAssignedError
        case TemplateManagementError.zoneOverlap:
            L10n.Templates.zoneOverlap
        case TemplateManagementError.invalidZoneTimeRange:
            L10n.Templates.invalidZoneTimeRangeError
        case TemplateManagementError.templateNotFound,
             TemplateManagementError.overrideNotFound:
            L10n.Templates.scheduleNotFoundError
        case TemplateManagementError.networkFailure:
            L10n.Templates.networkError
        case TemplateManagementError.invalidResponse:
            L10n.Templates.invalidResponseError
        case TemplateManagementError.validationFailed(let message),
             TemplateManagementError.server(let message):
            message
        default:
            L10n.Common.pleaseTryAgain
        }
    }
}
