//
//  RemoteAuthDataSource.swift
//  Data
//
//  Created by Awan on 18/07/2026.
//

import Foundation
import AwaNetwork

public protocol AuthDataSource: Sendable {
    func requestOTP(email: String) async throws -> OTPRequestResponseDTO
    func verifyOTP(email: String, code: String, deviceId: String) async throws -> OTPVerifyResponseDTO
}

public final class RemoteAuthDataSource: AuthDataSource {
    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func requestOTP(email: String) async throws -> OTPRequestResponseDTO {
        let endpoint = AuthEndpoint.requestOTP(email: email)
        print("Here is my email : \(email)")
        return try await networkService.request(endpoint)
    }

    public func verifyOTP(email: String, code: String, deviceId: String) async throws -> OTPVerifyResponseDTO {
        let endpoint = AuthEndpoint.verifyOTP(email: email, code: code, deviceId: deviceId)
        return try await networkService.request(endpoint)
    }
}
