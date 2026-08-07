//
//  SessionEndpoint.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation
import AwaNetwork

enum SessionEndpoint: APIEndpoint {

    // MARK: - Session CRUD

    case getSession(sessionID: UUID)
    case getSessionsByDate(date: String)
    case getSessionsByDateRange(startDate: String, endDate: String)
    case updateSession(sessionID: UUID, UpdateSessionRequestDTO)
    case lockSession(sessionID: UUID)
    case unlockSession(sessionID: UUID)
    case deleteSession(sessionID: UUID)
    case completeSession(sessionID: UUID)
    case uncompleteSession(sessionID: UUID)
    // MARK: - Task ↔ Session

    case createTaskWithSessions(CreateTaskWithSessionsRequestDTO)
    case getTaskSessions(taskID: UUID)

    // MARK: - APIEndpoint

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)"
        case .getSessionsByDate(let date):
            return "/sessions/date/\(date)"
        case .getSessionsByDateRange:
            return "/sessions/range"
        case .updateSession(let sessionID, _):
            return "/sessions/\(sessionID.uuidString)"
        case .lockSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)/lock"
        case .unlockSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)/unlock"
        case .deleteSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)"
        case .createTaskWithSessions:
            return "/tasks/with-sessions"
        case .getTaskSessions(let taskID):
            return "/tasks/\(taskID.uuidString)/sessions"
        case .completeSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)/complete"
        case .uncompleteSession(let sessionID):
            return "/sessions/\(sessionID.uuidString)/uncomplete"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getSession, .getTaskSessions, .getSessionsByDate, .getSessionsByDateRange:
            return .get
        case .createTaskWithSessions:
            return .post
        case .updateSession:
            return .put
        case .lockSession, .unlockSession:
            return .patch
        case .deleteSession:
            return .delete
        case .completeSession, .uncompleteSession:
            return .post
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .getSessionsByDateRange(startDate, endDate):
            return [
                "startDate": startDate,
                "endDate": endDate,
            ]
        default:
            return nil
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .updateSession(_, let request):
            return request
        case .createTaskWithSessions(let request):
            return request
        default:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
