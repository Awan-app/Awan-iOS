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
    case add
}

public enum MainRoute: Hashable, Identifiable, Sendable {
    case home
    case add
    case dailyZones

    public var id: Self { self }
}
