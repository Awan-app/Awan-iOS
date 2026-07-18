//
//  NetworkServices.swift
//  Network
//
//  Created by Me3bed on 18/07/2026.
//

import Foundation


public protocol NetworkServiceProtocol: Sendable {
 
    func request<T: Decodable>(_ endpoint: any APIEndpoint) async throws -> T
}
