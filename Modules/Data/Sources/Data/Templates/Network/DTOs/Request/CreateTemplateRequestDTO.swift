//
//  CreateTemplateRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct CreateTemplateRequestDTO: Encodable, Sendable {
    public let name: String
    public let daysOfWeek: [String]?
    public let zones: [ZonePayload]?

    public init(
        name: String,
        daysOfWeek: [String]? = nil,
        zones: [ZonePayload]? = nil
    ) {
        self.name = name
        self.daysOfWeek = daysOfWeek
        self.zones = zones
    }

    public struct ZonePayload: Encodable, Sendable {
        public let name: String
        public let startTime: String
        public let endTime: String
        public let color: String?

        public init(
            name: String,
            startTime: String,
            endTime: String,
            color: String? = nil
        ) {
            self.name = name
            self.startTime = startTime
            self.endTime = endTime
            self.color = color
        }
    }
}
