//
//  MainRoute.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import Foundation

public enum MainTab: Hashable, Sendable {
    case home
    case calendar
    case rewards
    case you
}

public enum MainRoute: Hashable, Identifiable, Sendable {
    case home

    public var id: Self { self }
}
