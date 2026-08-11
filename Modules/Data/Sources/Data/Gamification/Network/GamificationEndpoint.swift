//
//  GamificationEndpoint.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//

import AwaNetwork

enum GamificationEndpoint: APIEndpoint {
    case getProgress
    case getWheelConfig
    case spinWheel
    case getStoreItems(type: String)
    case buyStoreItem(itemID: String)
    case equipStoreItem(itemID: String)
    case unequipStoreItem(type: String)
    case getEquippedItems
    case getStoreInventory
    case activityDates(startDate: String, endDate: String)

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .getProgress:
            return "/gamification/progress"

        case .getWheelConfig:
            return "/gamification/wheel/config"

        case .spinWheel:
            return "/gamification/wheel/spin"

        case .getStoreItems:
            return "/store/items"

        case let .buyStoreItem(itemID):
            return "/store/items/\(itemID)/buy"

        case let .equipStoreItem(itemID):
            return "/store/items/\(itemID)/equip"

        case let .unequipStoreItem(type):
            return "/store/equipped/\(type)"

        case .getEquippedItems:
            return "/store/equipped"

        case .getStoreInventory:
            return "/store/inventory"
          
        case .activityDates: 
            return "/gamification/activity-dates"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProgress,
             .getWheelConfig,
             .getStoreItems,
             .getEquippedItems,
             .activityDates,
             .getStoreInventory:
            return .get

        case .spinWheel,
             .buyStoreItem,
             .equipStoreItem:
            return .post

        case .unequipStoreItem:
            return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .getStoreItems(type):
            return ["type": type]

        case .getProgress,
             .getWheelConfig,
             .spinWheel,
             .buyStoreItem,
             .equipStoreItem,
             .unequipStoreItem,
             .getEquippedItems,
             .getStoreInventory:
            return nil
        case let .activityDates(startDate, endDate):
            return ["startDate": startDate, "endDate": endDate]
        }
    }

    var body: (any Encodable)? {
        nil
    }

    var requiresAuthentication: Bool {
        true
    }
}
