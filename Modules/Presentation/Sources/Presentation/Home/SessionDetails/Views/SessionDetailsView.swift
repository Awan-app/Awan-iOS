import Common
import SwiftUI

struct SessionDetailsView: View {
    @State private var viewModel: SessionDetailsViewModel
    let onDismiss: () -> Void

    init(
        viewModel: SessionDetailsViewModel,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        let state = viewModel.state

        ZStack {
            AppColors.sheetBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    SessionDetailsTaskSummaryView(
                        task: state.task,
                        color: state.color,
                        onClose: { viewModel.send(.attemptDismiss) },
                        onDelete: { viewModel.send(.requestDelete) }
                    )

                    SessionDetailsStatusView(
                        status: state.statusLabel,
                        isLocked: state.session.blocking,
                        lockLabel: state.lockLabel
                    )

                    SessionDetailsDateView(
                        selectedDay: state.selectedDay,
                        isEnabled: !state.isBusy,
                        onChange: { viewModel.send(.setDay($0)) }
                    )

                    SessionDetailsScheduleView(
                        start: state.draftStart,
                        end: state.draftEnd,
                        durationMinutes: state.durationMinutes,
                        selectedDurationMinutes: state.selectedDurationMinutes,
                        validationMessage: state.validationMessage,
                        isEnabled: !state.isBusy,
                        onStartChange: { viewModel.send(.setStartTime($0)) },
                        onEndChange: { viewModel.send(.setEndTime($0)) },
                        onAdjustStart: {
                            viewModel.send(.adjustStart(minutes: $0))
                        },
                        onAdjustEnd: {
                            viewModel.send(.adjustEnd(minutes: $0))
                        },
                        onSelectDuration: {
                            viewModel.send(.selectDuration(minutes: $0))
                        }
                    )

                    SessionDetailsActionsView(
                        canSave: state.canSave,
                        isSaving: state.isSaving,
                        isLocking: state.isLocking,
                        isLocked: state.session.blocking,
                        onSave: { viewModel.send(.save) },
                        onToggleLock: { viewModel.send(.toggleLock) }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 42)
            }

            if let confirmation = state.confirmation {
                SessionDetailsConfirmationOverlay(
                    confirmation: confirmation,
                    isDeleting: state.isDeleting,
                    onCancel: { viewModel.send(.cancelConfirmation) },
                    onConfirmDelete: { viewModel.send(.confirmDelete) },
                    onDiscard: { viewModel.send(.discardAndDismiss) }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(2)
            }
        }
        .animation(.snappy(duration: 0.22), value: state.confirmation)
        .background {
            SheetDismissAttemptObserver(
                isDismissalDisabled: state.isDirty || state.isBusy,
                onAttempt: { viewModel.send(.attemptDismiss) }
            )
        }
        .interactiveDismissDisabled(state.isDirty || state.isBusy)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onChange(of: state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onDismiss()
            }
        }
        .alert(
            L10n.Home.errorTitle,
            isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { if !$0 { viewModel.send(.dismissError) } }
            )
        ) {
            Button(L10n.Common.gotIt) { viewModel.send(.dismissError) }
        } message: {
            Text(state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }
}
