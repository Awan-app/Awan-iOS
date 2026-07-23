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
    public var selectedTab: MainTab = .home
    public var homePath = NavigationPath()
    public var calendarPath = NavigationPath()
    public var rewardsPath = NavigationPath()
    public var youPath = NavigationPath()
    public var presentedSheet: MainRoute?

    public init() {}

    public func push(_ route: AnyHashable) {
        mutateSelectedPath { $0.append(route) }
    }

    public func pop() {
        mutateSelectedPath {
            guard !$0.isEmpty else { return }
            $0.removeLast()
        }
    }

    public func popToRoot() {
        mutateSelectedPath { $0 = NavigationPath() }
    }

    public func present(sheet route: AnyHashable) {
        if let mainRoute = route.base as? MainRoute {
            presentedSheet = mainRoute
        }
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func push(_ route: MainRoute) {
        mutateSelectedPath { $0.append(route) }
    }

    public func present(sheet route: MainRoute) {
        presentedSheet = route
    }

    private func mutateSelectedPath(_ mutation: (inout NavigationPath) -> Void) {
        switch selectedTab {
        case .home:
            mutation(&homePath)
        case .calendar:
            mutation(&calendarPath)
        case .rewards:
            mutation(&rewardsPath)
        case .you:
            mutation(&youPath)
        }
    }
}
