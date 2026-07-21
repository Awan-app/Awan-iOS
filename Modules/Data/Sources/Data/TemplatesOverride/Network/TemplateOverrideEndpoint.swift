//
//  File.swift
//  Data
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Foundation
import AwaNetwork


// MARK: - Endpoint

enum TemplateOverrideEndpoint: APIEndpoint {
    
    case createOverride(CreateTemplateOverrideRequestDTO)
    case listOverrides
    case getOverride(overrideId: UUID)
    case updateOverride(overrideId: UUID, UpdateTemplateOverrideRequestDTO)
    case deleteOverride(overrideId: UUID)
    case addZone(overrideId: UUID, AddZoneRequestDTO)
    case getZones(overrideId: UUID)
    
    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .createOverride, .listOverrides:
            return "/template-overrides"
        case .getOverride(let overrideId), .updateOverride(let overrideId, _), .deleteOverride(let overrideId):
            return "/template-overrides/\(overrideId.uuidString)"
        case .addZone(let overrideId, _), .getZones(let overrideId):
            return "/template-overrides/\(overrideId.uuidString)/zones"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createOverride, .addZone:
            return .post
        case .listOverrides, .getOverride, .getZones:
            return .get
        case .updateOverride:
            return .put
        case .deleteOverride:
            return .delete
        }
    }
    
    var queryParameters: [String: String]? {
        nil
    }
    
    var body: (any Encodable)? {
        switch self {
        case .createOverride(let request):
            return request
        case .updateOverride(_, let request):
            return request
        case .addZone(_, let request):
            return request
        default:
            return nil
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
}
