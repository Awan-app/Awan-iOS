import AwaNetwork

enum CategoryEndpoint: APIEndpoint {
    case list
    case create(CreateCategoryRequestDTO)

    var baseURL: String { NetworkConfiguration.apiBaseURL }
    var path: String { "/categories" }

    var method: HTTPMethod {
        switch self {
        case .list: .get
        case .create: .post
        }
    }

    var queryParameters: [String: String]? { nil }

    var body: (any Encodable)? {
        switch self {
        case .list: nil
        case .create(let request): request
        }
    }

    var requiresAuthentication: Bool { true }
}
