import Common
import SwiftUI

struct GlobalCreationSheet: View {
    @State private var selectedMode: CreationMode = .task
    @State private var taskViewModel: CreateTaskViewModel

    private let onDismiss: () -> Void
    private let onTaskSchedulingModeChanged: (Bool) -> Void

    init(
        taskViewModel: CreateTaskViewModel,
        onDismiss: @escaping () -> Void,
        onTaskSchedulingModeChanged: @escaping (Bool) -> Void
    ) {
        _taskViewModel = State(initialValue: taskViewModel)
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
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .interactiveDismissDisabled(taskViewModel.isSubmitting)
    }
}
