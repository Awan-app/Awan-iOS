//
//  NetworkServices.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation


public struct MultipartFile: Sendable {
    public let data: Data
    public let name: String
    public let fileName: String
    public let mimeType: String

    public init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T
    func uploadMultipart<T: Decodable>(
        _ endpoint: any APIEndpoint,
        files: [MultipartFile],
        parameters: [String: String]?
    ) async throws -> T
}
