//
//  TaskEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum TaskEndpoint: APIEndpoint {

    case createTask(CreateTaskRequestDTO)
    case getTask(taskID: UUID)
    case updateTask(taskID: UUID, UpdateTaskRequestDTO)
    case moveTask(taskID: UUID, MoveTaskRequestDTO)
    case deleteTask(taskID: UUID, cascade: Bool)
    case addDependency(taskID: UUID, AddDependencyRequestDTO)
    case removeDependency(taskID: UUID, dependsOnTaskID: UUID)
    case listDependencies(taskID: UUID)
    case listDependents(taskID: UUID)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .createTask:
            return "/tasks"
        case .getTask(let taskID):
            return "/tasks/\(taskID.uuidString)"
        case .updateTask(let taskID, _):
            return "/tasks/\(taskID.uuidString)"
        case .moveTask(let taskID, _):
            return "/tasks/\(taskID.uuidString)/move"
        case .deleteTask(let taskID, _):
            return "/tasks/\(taskID.uuidString)"
        case .addDependency(let taskID, _):
            return "/tasks/\(taskID.uuidString)/dependencies"
        case .removeDependency(let taskID, let dependsOnTaskID):
            return "/tasks/\(taskID.uuidString)/dependencies/\(dependsOnTaskID.uuidString)"
        case .listDependencies(let taskID):
            return "/tasks/\(taskID.uuidString)/dependencies"
        case .listDependents(let taskID):
            return "/tasks/\(taskID.uuidString)/dependents"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createTask, .addDependency:
            return .post
        case .getTask, .listDependencies, .listDependents:
            return .get
        case .updateTask, .moveTask:
            return .patch
        case .deleteTask, .removeDependency:
            return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .deleteTask(_, let cascade):
            return ["cascade": String(cascade)]
        default:
            return nil
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .createTask(let request):
            return request
        case .updateTask(_, let request):
            return request
        case .moveTask(_, let request):
            return request
        case .addDependency(_, let request):
            return request
        default:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
