//
//  TemplateEndpoint.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation
import AwaNetwork

enum TemplateEndpoint: APIEndpoint {

    // MARK: - Template CRUD

    case createTemplate(CreateTemplateRequestDTO)
    case listTemplates
    case getTemplate(templateID: UUID)
    case updateTemplate(templateID: UUID, UpdateTemplateRequestDTO)
    case deleteTemplate(templateID: UUID)

    // MARK: - Template Zones

    case addZone(templateID: UUID, AddZoneRequestDTO)
    case getZones(templateID: UUID)

    // MARK: - APIEndpoint

    var baseURL: String {
        NetworkConfiguration.apiBaseURL
    }

    var path: String {
        switch self {
        case .createTemplate, .listTemplates:
            return "/templates"
        case .getTemplate(let templateID):
            return "/templates/\(templateID.uuidString)"
        case .updateTemplate(let templateID, _):
            return "/templates/\(templateID.uuidString)"
        case .deleteTemplate(let templateID):
            return "/templates/\(templateID.uuidString)"
        case .addZone(let templateID, _):
            return "/templates/\(templateID.uuidString)/zones"
        case .getZones(let templateID):
            return "/templates/\(templateID.uuidString)/zones"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createTemplate, .addZone:
            return .post
        case .listTemplates, .getTemplate, .getZones:
            return .get
        case .updateTemplate:
            return .put
        case .deleteTemplate:
            return .delete
        }
    }

    var queryParameters: [String: String]? {
        nil
    }

    var body: (any Encodable)? {
        switch self {
        case .createTemplate(let request):
            return request
        case .updateTemplate(_, let request):
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
