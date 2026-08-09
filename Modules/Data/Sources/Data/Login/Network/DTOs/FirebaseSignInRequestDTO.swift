//
//  FirebaseSignInRequestDTO.swift
//  Data
//
//  Created by Agent on 18/07/2026.
//

import Foundation

public struct FirebaseSignInRequestDTO: Codable, Sendable {
    public let idToken: String
    public let deviceId: String

    public init(idToken: String, deviceId: String) {
        self.idToken = idToken
        self.deviceId = deviceId
    }
}
