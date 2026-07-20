//
//  GoalEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum GoalEndpoint: APIEndpoint {

    case createGoal(CreateGoalRequestDTO)
    case listGoals(ListGoalsParameters)
    case getInbox
    case getGoal(goalId: UUID, expand: Bool)
    case getGoalTasks(goalId: UUID)
    case bulkAddTasks(goalId: UUID, BulkAddTasksRequestDTO)
    case updateGoal(goalId: UUID, UpdateGoalRequestDTO)
    case deleteGoal(goalId: UUID)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .createGoal, .listGoals:
            return "/goals"
        case .getInbox:
            return "/goals/inbox"
        case .getGoal(let goalId, _):
            return "/goals/\(goalId.uuidString)"
        case .getGoalTasks(let goalId):
            return "/goals/\(goalId.uuidString)/tasks"
        case .bulkAddTasks(let goalId, _):
            return "/goals/\(goalId.uuidString)/tasks/bulk"
        case .updateGoal(let goalId, _):
            return "/goals/\(goalId.uuidString)"
        case .deleteGoal(let goalId):
            return "/goals/\(goalId.uuidString)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createGoal, .bulkAddTasks:
            return .post
        case .listGoals, .getInbox, .getGoal, .getGoalTasks:
            return .get
        case .updateGoal:
            return .patch
        case .deleteGoal:
            return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .listGoals(let params):
            return params.asQueryParameters()
        case .getGoal(_, let expand):
            return ["expand": String(expand)]
        default:
            return nil
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .createGoal(let request):
            return request
        case .bulkAddTasks(_, let request):
            return request
        case .updateGoal(_, let request):
            return request
        default:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}

public struct ListGoalsParameters: Sendable {
    public let status: String?
    public let includeInbox: Bool?
    public let expand: Bool?
    public let page: Int?
    public let size: Int?
    public let sort: String?

    public init(
        status: String? = nil,
        includeInbox: Bool? = nil,
        expand: Bool? = nil,
        page: Int? = nil,
        size: Int? = nil,
        sort: String? = nil
    ) {
        self.status = status
        self.includeInbox = includeInbox
        self.expand = expand
        self.page = page
        self.size = size
        self.sort = sort
    }

    func asQueryParameters() -> [String: String]? {
        var params: [String: String] = [:]
        if let status       { params["status"]       = status }
        if let includeInbox { params["includeInbox"] = String(includeInbox) }
        if let expand       { params["expand"]       = String(expand) }
        if let page         { params["page"]         = String(page) }
        if let size         { params["size"]         = String(size) }
        if let sort         { params["sort"]         = sort }
        return params.isEmpty ? nil : params
    }
}
