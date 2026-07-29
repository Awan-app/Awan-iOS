//
//  AiTaskEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum AiTaskEndpoint: APIEndpoint {

    case createAITask(CreateAITaskRequestDTO)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .createAITask:
            return "/ai/task-create"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createAITask:
            return .post
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .createAITask:
            return ["persist": "false"]
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .createAITask(let request):
            return request
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
