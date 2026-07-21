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
    case updateSession(sessionID: UUID, UpdateSessionRequestDTO)
    case updateSessionStatus(sessionID: UUID, status: String)
    case lockSession(sessionID: UUID)
    case unlockSession(sessionID: UUID)
    case deleteSession(sessionID: UUID)

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
        case .updateSession(let sessionID, _):
            return "/sessions/\(sessionID.uuidString)"
        case .updateSessionStatus(let sessionID, _):
            return "/sessions/\(sessionID.uuidString)/status"
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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getSession, .getTaskSessions:
            return .get
        case .createTaskWithSessions:
            return .post
        case .updateSession:
            return .put
        case .updateSessionStatus, .lockSession, .unlockSession:
            return .patch
        case .deleteSession:
            return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .updateSessionStatus(_, let status):
            return ["status": status]
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
