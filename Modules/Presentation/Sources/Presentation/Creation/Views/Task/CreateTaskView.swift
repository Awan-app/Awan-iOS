import Common
import Domain
import SwiftUI

struct CreateTaskView: View {
    @State private var viewModel: CreateTaskViewModel
    private let onCreated: () -> Void
    private let onLayoutModeChanged: (Bool, Bool) -> Void

    init(
        viewModel: CreateTaskViewModel,
        onCreated: @escaping () -> Void,
        onLayoutModeChanged: @escaping (Bool, Bool) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCreated = onCreated
        self.onLayoutModeChanged = onLayoutModeChanged
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        Group {
            switch viewModel.state.phase {
            case .composer:
                composerView(bindableViewModel: $bindableViewModel)
            case .aiLoading:
                GoalCreationLoadingView(message: L10n.Home.aiCreatingTask)
            case .aiTasksResult(let response):
                ImageToTasksResultSheet(
                    response: response,
                    categories: viewModel.state.categories,
                    zones: viewModel.state.zones,
                    categoryErrorMessage: viewModel.state.categoryErrorMessage,
                    onRetryCategories: viewModel.retryCategories,
                    onConfirm: { selectedTasks in
                        Task {
                            await viewModel.confirmAndAcceptProposedTasks(selectedTasks)
                        }
                    },
                    onAddToInbox: { selectedTasks in
                        Task {
                            await viewModel.confirmAndAddProposedTasksToInbox(selectedTasks)
                        }
                    },
                    defaultSessionStart: viewModel.state.startsAt,
                    onDismiss: {
                        viewModel.dismissAITaskResult()
                    }
                )
            case .imageUploading(let message):
                GoalCreationLoadingView(message: message)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .task {
            await viewModel.loadCreationData()
        }
        .onDisappear {
            viewModel.cancelRecording()
        }
        .onAppear {
            notifyLayoutModeChanged()
        }
        .onChange(of: viewModel.state.didCreateTask) { _, didCreateTask in
            if didCreateTask {
                onCreated()
            }
        }
        .onChange(of: viewModel.state.isAwanSchedulingEnabled) { _, isEnabled in
            onLayoutModeChanged(isEnabled, viewModel.state.isManualSchedulingEnabled)
        }
        .onChange(of: viewModel.state.isManualSchedulingEnabled) { _, isEnabled in
            onLayoutModeChanged(viewModel.state.isAwanSchedulingEnabled, isEnabled)
        }
        .alert(L10n.Home.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private func composerView(bindableViewModel: Bindable<CreateTaskViewModel>) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                QuickAddHeader(
                    isAwanSchedulingEnabled: viewModel.state.isAwanSchedulingEnabled
                )

                AwanSchedulingToggle(
                    isOn: bindableViewModel.state.isAwanSchedulingEnabled
                )

                if !viewModel.state.isAwanSchedulingEnabled {
                    ManualScheduleControls(
                        categories: viewModel.state.categories,
                        zones: viewModel.state.zones,
                        categoryErrorMessage: viewModel.state.categoryErrorMessage,
                        onRetryCategories: viewModel.retryCategories,
                        isSchedulingEnabled: bindableViewModel.state.isManualSchedulingEnabled,
                        startsAt: bindableViewModel.state.startsAt,
                        durationMinutes: bindableViewModel.state.durationMinutes,
                        selectedCategoryID: bindableViewModel.state.selectedCategoryID
                    )
                }

                QuickTaskComposer(
                    text: bindableViewModel.state.quickText,
                    isRecording: viewModel.state.isRecording,
                    onSend: {
                        Task {
                            await viewModel.submitCurrentTask()
                        }
                    },
                    onRecordingStarted: {
                        Task {
                            await viewModel.beginRecording()
                        }
                    },
                    onRecordingEnded: {
                        Task {
                            await viewModel.finishRecording()
                        }
                    },
                    onPhotoItemSelected: { item in
                        Task {
                            await viewModel.processPickedPhoto(item, note: nil)
                        }
                    },
                    onCameraImageCaptured: { data in
                        Task {
                            await viewModel.processCapturedImage(data, note: nil)
                        }
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .animation(
                .spring(response: 0.32, dampingFraction: 0.8),
                value: viewModel.state.isAwanSchedulingEnabled
            )
        }
        .disabled(viewModel.state.isSubmitting)
        .overlay {
            if viewModel.state.isLoadingZones {
                ProgressView()
                    .controlSize(.large)
                    .padding(22)
                    .background(
                        AppMaterials.loadingOverlay,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    private func notifyLayoutModeChanged() {
        onLayoutModeChanged(
            viewModel.state.isAwanSchedulingEnabled,
            viewModel.state.isManualSchedulingEnabled
        )
    }
}
