import AwaNetwork
import Foundation

enum CategoryEndpoint: APIEndpoint {
    case list
    case create(CreateCategoryRequestDTO)
    case update(id: UUID, request: UpdateCategoryRequestDTO)
    case delete(id: UUID)

    var baseURL: String { NetworkConfiguration.apiBaseURL }
    var path: String {
        switch self {
        case .list, .create:
            return "/categories"
        case .update(let id, _), .delete(let id):
            return "/categories/\(id.uuidString.lowercased())"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list: .get
        case .create: .post
        case .update: .put
        case .delete: .delete
        }
    }

    var queryParameters: [String: String]? { nil }

    var body: (any Encodable)? {
        switch self {
        case .list, .delete: nil
        case .create(let request): request
        case .update(_, let request): request
        }
    }

    var requiresAuthentication: Bool { true }
}

