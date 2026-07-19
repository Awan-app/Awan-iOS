//
//  OTPRequestResult.swift
//  Domain
//
//  Created by Awan on 18/07/2026.
//

import Foundation

public struct OTPRequestResult: Sendable, Equatable {
    public let expiresInSeconds: Int
    public let resendAvailableInSeconds: Int
    
    public init(expiresInSeconds: Int, resendAvailableInSeconds: Int) {
        self.expiresInSeconds = expiresInSeconds
        self.resendAvailableInSeconds = resendAvailableInSeconds
    }
}
