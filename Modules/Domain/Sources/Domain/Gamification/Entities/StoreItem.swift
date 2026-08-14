//
//  StoreItem.swift
//  Domain
//

import Foundation

public enum StoreItemType: String, CaseIterable, Equatable, Sendable {
    case frame = "FRAME"
    case skin = "SKIN"
    case theme = "THEME"
    case icon = "ICON"
    case unknown = "UNKNOWN"

    public init(apiValue: String) {
        switch apiValue.uppercased() {
        case Self.frame.rawValue:
            self = .frame
        case Self.skin.rawValue:
            self = .skin
        case Self.theme.rawValue:
            self = .theme
        case Self.icon.rawValue, "APPICON":
            self = .icon
        default:
            self = .unknown
        }
    }
}

public struct StoreItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let image: String
    public let info: String?
    public let price: Int
    public let version: String
    public let type: StoreItemType

    public init(
        id: String,
        name: String,
        description: String,
        image: String,
        info: String?,
        price: Int,
        version: String,
        type: StoreItemType
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.info = info
        self.price = price
        self.version = version
        self.type = type
    }
}
