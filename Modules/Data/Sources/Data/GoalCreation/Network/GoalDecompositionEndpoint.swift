import AwaNetwork
import Foundation

enum GoalDecompositionEndpoint: APIEndpoint {
    case sendMessage(SendGoalDecompositionMessageRequestDTO)
    case confirm(sessionID: UUID)
    case schedule(ScheduleGoalRequestDTO)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .sendMessage:
            "/ai/goal-decompose"
        case .confirm(let sessionID):
            "/ai/goal-decompose/\(sessionID.uuidString)/confirm"
        case .schedule:
            "/schedule"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var queryParameters: [String: String]? {
        nil
    }

    var body: (any Encodable)? {
        switch self {
        case .sendMessage(let request):
            request
        case .confirm:
            nil
        case .schedule(let request):
            request
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
