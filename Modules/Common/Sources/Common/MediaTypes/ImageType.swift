//
//  ImageType.swift
//  Common
//

import UniformTypeIdentifiers

public enum ImageType: String, Sendable {
    case jpeg = "image/jpeg"
    case png  = "image/png"
    case webp = "image/webp"
    case gif  = "image/gif"

    public static func from(_ utType: UTType?) -> ImageType {
        guard let mimeString = utType?.preferredMIMEType else { return .jpeg }
        return ImageType(rawValue: mimeString) ?? .jpeg
    }
}
