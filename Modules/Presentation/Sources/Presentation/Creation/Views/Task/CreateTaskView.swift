import Common
import SwiftUI

struct CreateTaskView: View {
    @State private var viewModel: CreateTaskViewModel
    private let onCreated: () -> Void
    private let onSchedulingModeChanged: (Bool) -> Void

    init(
        viewModel: CreateTaskViewModel,
        onCreated: @escaping () -> Void,
        onSchedulingModeChanged: @escaping (Bool) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCreated = onCreated
        self.onSchedulingModeChanged = onSchedulingModeChanged
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                QuickAddHeader(
                    isAwanSchedulingEnabled: viewModel.isAwanSchedulingEnabled
                )

                AwanSchedulingToggle(
                    isOn: $bindableViewModel.isAwanSchedulingEnabled
                )

                if !viewModel.isAwanSchedulingEnabled {
                    ManualScheduleControls(
                        zones: viewModel.zones,
                        startsAt: $bindableViewModel.startsAt,
                        durationMinutes: $bindableViewModel.durationMinutes,
                        selectedZoneID: $bindableViewModel.selectedZoneID
                    )
                }

                QuickTaskComposer(
                    text: $bindableViewModel.quickText,
                    isRecording: viewModel.isRecording,
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
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .animation(
                .spring(response: 0.32, dampingFraction: 0.8),
                value: viewModel.isAwanSchedulingEnabled
            )
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .disabled(viewModel.isSubmitting)
        .overlay {
            // Only show the spinner for zone loading; the AI loading uses its own sheet.
            if viewModel.isLoadingZones {
                ProgressView()
                    .controlSize(.large)
                    .padding(22)
                    .background(
                        AppMaterials.loadingOverlay,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
        }
        // Loading sheet — shown while AI endpoint is being called.
        .sheet(isPresented: aiLoadingBinding) {
            GoalCreationLoadingView(message: L10n.Home.aiCreatingTask)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        // Result sheet — shown once the AI response arrives.
        .sheet(item: aiTaskResultBinding) { sheetItem in
            AITaskResultSheet(item: sheetItem) {
                viewModel.dismissAITaskResult()
                onCreated()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadCreationData()
        }
        .onDisappear {
            viewModel.cancelRecording()
        }
        .onChange(of: viewModel.didCreateTask) { _, didCreateTask in
            if didCreateTask {
                onCreated()
            }
        }
        .onChange(of: viewModel.isAwanSchedulingEnabled) { _, isEnabled in
            onSchedulingModeChanged(isEnabled)
        }
        .alert(L10n.Home.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    private var aiLoadingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingAILoading },
            set: { _ in } // dismissal is controlled by the ViewModel
        )
    }

    private var aiTaskResultBinding: Binding<AITaskSheetItem?> {
        Binding(
            get: { viewModel.pendingAITaskItem },
            set: { if $0 == nil { viewModel.dismissAITaskResult() } }
        )
    }
}
