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

        AppSheet(
            sizing: .content(initialHeight: 720, maximumHeight: 900),
            backgroundColor: AppColors.sheetBackground
        ) {
            ZStack {
                VStack(spacing: 22) {
                    SessionDetailsTaskSummaryView(
                        task: state.task,
                        color: state.color,
                        arePointsClaimed: state.session.firstCompletedAt != nil,
                        onClose: { viewModel.send(.attemptDismiss) },
                        onDelete: { viewModel.send(.requestDelete) }
                    )

                    SessionDetailsStatusView(
                        status: state.statusUIModel,
                        isLocked: state.session.blocking,
                        lockLabel: state.lockLabel
                    )

                    SessionDetailsScheduleView(
                        selectedDay: state.selectedDay,
                        start: state.draftStart,
                        end: state.draftEnd,
                        durationMinutes: state.durationMinutes,
                        selectedDurationMinutes: state.selectedDurationMinutes,
                        validationMessage: state.validationMessage,
                        isEnabled: !state.isBusy,
                        onDayChange: { viewModel.send(.setDay($0)) },
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
                .padding(.horizontal, 12)
                .padding(.top, 18)
                .padding(.bottom, 42)
                .background(AppColors.sheetBackground)

            }
            .frame(maxWidth: .infinity)
            .background(AppColors.sheetBackground)
        }
        .animation(.snappy(duration: 0.22), value: state.confirmation)
        .background {
            SheetDismissAttemptObserver(
                isDismissalDisabled: state.isDirty || state.isBusy,
                onAttempt: { viewModel.send(.attemptDismiss) }
            )
        }
        .interactiveDismissDisabled(state.isDirty || state.isBusy)
        .task {
            while !Task.isCancelled {
                viewModel.send(.refreshStatus)
                try? await Task.sleep(for: .seconds(30))
            }
        }
        .onChange(of: state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onDismiss()
            }
        }
        .alert(
            L10n.Home.closeSessionDetailsTitle,
            isPresented: Binding(
                get: {
                    viewModel.state.confirmation == .discardChanges
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.send(.cancelConfirmation)
                    }
                }
            )
        ) {
            Button(L10n.Home.keepEditing, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
            Button(L10n.Home.discardAndClose, role: .destructive) {
                viewModel.send(.discardAndDismiss)
            }
        } message: {
            Text(L10n.Home.closeSessionDetailsMessage)
        }
        .alert(
            L10n.Home.deleteSessionTitle,
            isPresented: Binding(
                get: { viewModel.state.confirmation == .delete },
                set: { isPresented in
                    if !isPresented {
                        viewModel.send(.cancelConfirmation)
                    }
                }
            )
        ) {
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
            Button(L10n.Home.deleteSession, role: .destructive) {
                viewModel.send(.confirmDelete)
            }
        } message: {
            Text(L10n.Home.deleteSessionMessage)
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
