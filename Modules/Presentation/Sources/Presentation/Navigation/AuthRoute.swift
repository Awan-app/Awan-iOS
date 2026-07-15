//
//  AuthRoute.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import Foundation

public enum AuthRoute: Hashable, Identifiable, Sendable {
    case login

    public var id: Self { self }
}
