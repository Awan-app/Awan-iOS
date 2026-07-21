//
//  UpdateSessionRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct UpdateSessionRequestDTO: Encodable, Sendable {
    public let start: String
    public let end: String
    public let status: String?

    public init(start: String, end: String, status: String? = nil) {
        self.start = start
        self.end = end
        self.status = status
    }
}
