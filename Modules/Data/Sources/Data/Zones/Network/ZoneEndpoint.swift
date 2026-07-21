//
//  ZoneEndpoint.swift
//  Data
//

import Foundation
import AwaNetwork

enum ZoneEndpoint: APIEndpoint {
    case getZone(zoneId: UUID)
    case getZoneSessions(zoneId: UUID)
    case getZonesByDate(date: String)
    case updateZone(zoneId: UUID, request: UpdateZoneRequestDTO)
    case deleteZone(zoneId: UUID)
    
    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }
    
    var path: String {
        switch self {
        case .getZone(let zoneId):
            return "/zones/\(zoneId.uuidString)"
        case .getZoneSessions(let zoneId):
            return "/zones/\(zoneId.uuidString)/sessions"
        case .getZonesByDate(let date):
            return "/zones/date/\(date)"
        case .updateZone(let zoneId, _):
            return "/v1/zones/\(zoneId.uuidString)"
        case .deleteZone(let zoneId):
            return "/v1/zones/\(zoneId.uuidString)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getZone, .getZoneSessions, .getZonesByDate:
            return .get
        case .updateZone:
            return .put
        case .deleteZone:
            return .delete
        }
    }
    
    var queryParameters: [String: String]? {
        nil
    }
    
    var body: (any Encodable)? {
        switch self {
        case .updateZone(_, let request):
            return request
        default:
            return nil
        }
    }
    
    var requiresAuthentication: Bool {
        true
    }
}
