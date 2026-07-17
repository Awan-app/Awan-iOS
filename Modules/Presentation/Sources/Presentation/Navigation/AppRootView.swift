//
//  AppRootView.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI

public struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    private let scheduleViewModel: ScheduleTimelineViewModel

    public init(scheduleViewModel: ScheduleTimelineViewModel) {
        self.scheduleViewModel = scheduleViewModel
    }

    public var body: some View {
        switch coordinator.currentFlow {
        case .auth:
            NavigationStack(path: Bindable(coordinator.authCoordinator).path) {
                EmptyView()
            }
        case .main:
            NavigationStack(path: Bindable(coordinator.mainCoordinator).path) {
                ScheduleTimelineView(viewModel: scheduleViewModel)
            }
        }
    }
}
