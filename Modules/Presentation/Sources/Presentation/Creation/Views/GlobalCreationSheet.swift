import Common
import SwiftUI

struct GlobalCreationSheet: View {
    @State private var selectedMode: CreationMode = .task
    @State private var taskViewModel: CreateTaskViewModel
    @State private var goalViewModel: CreateGoalViewModel

    private let onDismiss: () -> Void
    private let onTaskSchedulingModeChanged: (Bool) -> Void
    private let onGoalFullScreenChanged: (Bool) -> Void

    init(
        taskViewModel: CreateTaskViewModel,
        goalViewModel: CreateGoalViewModel,
        onDismiss: @escaping () -> Void,
        onTaskSchedulingModeChanged: @escaping (Bool) -> Void,
        onGoalFullScreenChanged: @escaping (Bool) -> Void
    ) {
        _taskViewModel = State(initialValue: taskViewModel)
        _goalViewModel = State(initialValue: goalViewModel)
        self.onDismiss = onDismiss
        self.onTaskSchedulingModeChanged = onTaskSchedulingModeChanged
        self.onGoalFullScreenChanged = onGoalFullScreenChanged
    }

    var body: some View {
        VStack(spacing: 0) {
            if !goalViewModel.requiresFullScreen {
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
                    onSchedulingModeChanged: onTaskSchedulingModeChanged
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
            taskViewModel.isSubmitting || goalViewModel.phase == .confirming
        )
    }
}
