//
//  InboxRoute.swift
//  Presentation
//

import Foundation

public enum InboxRoute: Hashable, Identifiable, Sendable {
    case goalDetail(UUID)

    public var id: Self { self }
}
