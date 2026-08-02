//
//  AiTaskEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum AiTaskEndpoint: APIEndpoint {

    case createAITask(CreateAITaskRequestDTO)
    case imageToTasks

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .createAITask:
            return "/ai/task-create"
        case .imageToTasks:
            return "/ai/image-to-tasks"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createAITask, .imageToTasks:
            return .post
        }
    }

    var queryParameters: [String: String]? {
        return nil
       
    }

    var body: (any Encodable)? {
        switch self {
        case .createAITask(let request):
            return request
        case .imageToTasks:
            return nil
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
