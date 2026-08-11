import Common
import SwiftUI

struct GlobalCreationSheet: View {
    @State private var selectedMode: CreationMode = .task
    @State private var taskViewModel: CreateTaskViewModel
    @State private var goalViewModel: CreateGoalViewModel

    private let onDismiss: () -> Void
    private let onTaskLayoutModeChanged: (Bool, Bool) -> Void
    private let onGoalFullScreenChanged: (Bool) -> Void

    init(
        taskViewModel: CreateTaskViewModel,
        goalViewModel: CreateGoalViewModel,
        onDismiss: @escaping () -> Void,
        onTaskLayoutModeChanged: @escaping (Bool, Bool) -> Void,
        onGoalFullScreenChanged: @escaping (Bool) -> Void
    ) {
        _taskViewModel = State(initialValue: taskViewModel)
        _goalViewModel = State(initialValue: goalViewModel)
        self.onDismiss = onDismiss
        self.onTaskLayoutModeChanged = onTaskLayoutModeChanged
        self.onGoalFullScreenChanged = onGoalFullScreenChanged
    }

    var body: some View {
        VStack(spacing: 0) {
            if !goalViewModel.state.requiresFullScreen {
                CreationModeSwitcher(selectedMode: $selectedMode)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
            }
    
            switch selectedMode {
            case .task:
                CreateTaskView(
                    viewModel: taskViewModel,
                    onCreated: onDismiss,
                    onLayoutModeChanged: onTaskLayoutModeChanged
                )
            case .goal:
                CreateGoalView(
                    viewModel: goalViewModel,
                    onGoalScheduled: onDismiss,
                    onFullScreenChanged: onGoalFullScreenChanged
                )
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .interactiveDismissDisabled(
            taskViewModel.state.isSubmitting || goalViewModel.state.isBusy
        )
    }
}
