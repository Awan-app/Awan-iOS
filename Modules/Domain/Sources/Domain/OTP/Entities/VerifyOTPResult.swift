//
//  VerifyOTPResult.swift
//  Domain
//

import Foundation

public struct UserEntity: Equatable, Sendable {
    public let id: String
    public let email: String
    public let isNew: Bool

    public init(id: String, email: String, isNew: Bool) {
        self.id = id
        self.email = email
        self.isNew = isNew
    }
}

public struct VerifyOTPResult: Equatable, Sendable {
    public let user: UserEntity

    public init(user: UserEntity) {
        self.user = user
    }
}
