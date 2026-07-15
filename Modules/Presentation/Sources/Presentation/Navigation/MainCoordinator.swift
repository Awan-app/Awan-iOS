//
//  MainCoordinator.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI
import Common

@Observable
@MainActor
public final class MainCoordinator: Coordinating {

    public var path: NavigationPath = NavigationPath()
    public var presentedSheet: MainRoute?

    public init() {}

    public func push(_ route: AnyHashable) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func present(sheet route: AnyHashable) {
        presentedSheet = route.base as? MainRoute
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func push(_ route: MainRoute) {
        path.append(route)
    }

    public func present(sheet route: MainRoute) {
        presentedSheet = route
    }
}
