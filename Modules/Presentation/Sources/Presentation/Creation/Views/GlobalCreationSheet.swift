import Common
import SwiftUI

struct GlobalCreationSheet: View {
    @State private var selectedMode: CreationMode = .task
    @State private var taskViewModel: CreateTaskViewModel
    @State private var goalViewModel: CreateGoalViewModel

    private let onDismiss: () -> Void
    private let onTaskSchedulingModeChanged: (Bool) -> Void

    init(
        taskViewModel: CreateTaskViewModel,
        goalViewModel: CreateGoalViewModel,
        onDismiss: @escaping () -> Void,
        onTaskSchedulingModeChanged: @escaping (Bool) -> Void
    ) {
        _taskViewModel = State(initialValue: taskViewModel)
        _goalViewModel = State(initialValue: goalViewModel)
        self.onDismiss = onDismiss
        self.onTaskSchedulingModeChanged = onTaskSchedulingModeChanged
    }

    var body: some View {
        VStack(spacing: 0) {
            CreationModeSwitcher(selectedMode: $selectedMode)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
    
            switch selectedMode {
            case .task:
                CreateTaskView(
                    viewModel: taskViewModel,
                    onCreated: onDismiss,
                    onSchedulingModeChanged: onTaskSchedulingModeChanged
                )
            case .goal:
                CreateGoalView(viewModel: goalViewModel)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .interactiveDismissDisabled(taskViewModel.isSubmitting)
    }
}
