//
//  NetworkClient.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation
import Alamofire




public final class NetworkClient: NetworkServiceProtocol {

    // MARK: Singleton

    public static let shared = NetworkClient()


    private let session: Session
    private let jsonDecoder: JSONDecoder

    // MARK: Init

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        session = Session(configuration: configuration)

        jsonDecoder = JSONDecoder()
        // The API uses camelCase, so no key decoding strategy override is needed.
    }

    public func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T {
        let urlRequest = try buildURLRequest(from: endpoint)

        let dataResponse = await session
            .request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response

        return try decodeResponse(dataResponse)
    }



   
    private func buildURLRequest(from endpoint: any APIEndpoint) throws -> URLRequest {
        guard let url = endpoint.fullURL else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        // Default headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        // Endpoint-specific headers (may override defaults)
        for (key, value) in endpoint.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Encode body when present
        if let body = endpoint.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }

        return urlRequest
    }


    private func decodeResponse<T: Decodable>(_ response: DataResponse<Data, AFError>) throws -> T {
        switch response.result {
        case .success(let data):
            // 204 No Content path — return EmptyResponse without decoding.
            if data.isEmpty {
                if let empty = EmptyResponse() as? T {
                    return empty
                }
                // Caller used request<T> with a non-EmptyResponse type on a 204 endpoint.
                throw NetworkError.noContent
            }
            do {
                return try jsonDecoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }

        case .failure(let afError):
            throw try mapAlamofireError(afError, responseData: response.data)
        }
    }

    /// Maps an `AFError` (and optional raw response body) into a typed ``NetworkError``.
    private func mapAlamofireError(_ afError: AFError, responseData: Data?) throws -> NetworkError {
        // HTTP error — attempt to decode the standard API error envelope.
        if let statusCode = afError.responseCode {
            let apiError = responseData.flatMap {
                try? jsonDecoder.decode(APIErrorResponse.self, from: $0)
            }
            return .httpError(statusCode: statusCode, apiError: apiError)
        }

        return .underlying(afError)
    }
}

// MARK: - AnyEncodable

/// Type-erasing wrapper that lets `Encodable` existentials be encoded by `JSONEncoder`.
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ encodable: any Encodable) {
        encodeFunc = encodable.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
