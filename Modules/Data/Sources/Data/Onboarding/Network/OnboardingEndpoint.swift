import AwaNetwork

enum OnboardingEndpoint: APIEndpoint {
    case complete(OnboardingRequestDTO)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        "/onboarding"
    }

    var method: HTTPMethod {
        .post
    }

    var queryParameters: [String: String]? {
        nil
    }

    var body: (any Encodable)? {
        switch self {
        case .complete(let request):
            return request
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
