import Common
import Domain
import SwiftUI

struct CreateGoalView: View {
    @State private var viewModel: CreateGoalViewModel

    private let onGoalScheduled: () -> Void
    private let onFullScreenChanged: (Bool) -> Void

    init(
        viewModel: CreateGoalViewModel,
        onGoalScheduled: @escaping () -> Void,
        onFullScreenChanged: @escaping (Bool) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onGoalScheduled = onGoalScheduled
        self.onFullScreenChanged = onFullScreenChanged
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        ZStack {
            Group {
                switch viewModel.state.phase {
                case .starter:
                    starterView(text: $bindableViewModel.state.prompt)
                case .loading:
                    GoalCreationLoadingView(message: L10n.GoalCreation.planning)
                case .conversation(let blocks):
                    conversationView(
                        blocks: blocks,
                        text: $bindableViewModel.state.prompt
                    )
                case .proposal(let narration, let goal):
                    GoalProposalView(
                        narration: narration,
                        proposal: goal,
                        prompt: $bindableViewModel.state.prompt,
                        isRecording: viewModel.state.isRecording,
                        onSend: submitPrompt,
                        onOptionSelected: selectOption,
                        onRecordingStarted: startRecording,
                        onRecordingEnded: finishRecording,
                        onConfirm: confirmGoal
                    )
                case .confirmingGoal:
                    GoalCreationLoadingView(message: L10n.GoalCreation.scheduling)
                case .requestingSchedule:
                    GoalCreationLoadingView(message: L10n.GoalCreation.requestingSchedule)
                case .scheduleReview:
                    GoalScheduleReviewView(
                        tasks: viewModel.state.scheduleTasks,
                        zoneNames: viewModel.state.zoneNames,
                        focusedTaskID: viewModel.state.focusedUnscheduledTaskID,
                        onFocusHandled: viewModel.clearFocusedUnscheduledTask,
                        onToggleSuggestion: viewModel.toggleSuggestion,
                        onUpdateSession: viewModel.updateSession,
                        onAddManualSession: viewModel.addManualSession,
                        onRemoveManualSession: viewModel.removeManualSession,
                        onConfirm: confirmSchedule
                    )
                case .confirmingSchedule:
                    GoalCreationLoadingView(message: L10n.GoalCreation.confirmingSchedule)
                case .scheduleFailure(let message):
                    scheduleFailureView(message: message)
                }
            }
            .disabled(viewModel.state.showsUnscheduledDialog)

            if viewModel.state.showsUnscheduledDialog {
                UnscheduledTasksDialog(
                    taskTitles: viewModel.state.unresolvedTasks.map(\.title),
                    onAddSessions: viewModel.focusFirstUnscheduledTask,
                    onContinue: continueWithoutUnscheduledTasks,
                    onCancel: viewModel.dismissUnscheduledDialog
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(1)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .onChange(of: viewModel.state.requiresFullScreen, initial: true) { _, value in
            onFullScreenChanged(value)
        }
        .onDisappear { viewModel.cancelRecording() }
        .alert(L10n.Home.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) { viewModel.dismissError() }
        } message: {
            Text(viewModel.state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
        .animation(
            .snappy(duration: 0.22),
            value: viewModel.state.showsUnscheduledDialog
        )
    }

    private func starterView(text: Binding<String>) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                starterContent
                composer(text: text, placeholder: L10n.GoalCreation.promptPlaceholder)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }

    private func conversationView(
        blocks: [GoalDecompositionBlock],
        text: Binding<String>
    ) -> some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                GoalAssistantBlocksView(
                    blocks: blocks,
                    onOptionSelected: selectOption
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }

            composer(text: text, placeholder: L10n.GoalCreation.replyPlaceholder)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }

    private func composer(
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        QuickTaskComposer(
            text: text,
            isRecording: viewModel.state.isRecording,
            placeholder: placeholder,
            sendAccessibilityLabel: L10n.GoalCreation.sendPrompt,
            recordingAccessibilityLabel: L10n.Home.tellAwan,
            onSend: submitPrompt,
            onRecordingStarted: startRecording,
            onRecordingEnded: finishRecording
        )
    }

    private var starterContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.GoalCreation.header.uppercased())
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(L10n.GoalCreation.headline)
                        .font(AppFonts.bigTitle)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.GoalCreation.caption)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                AwanMascotView(state: .goal)
                    .frame(width: 150, height: 150)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func scheduleFailureView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)
            VStack(spacing: 8) {
                Text(L10n.GoalCreation.scheduleFailureTitle)
                    .font(AppFonts.title2Black)
                    .foregroundStyle(AppColors.textPrimary)
                Text(message)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            AppButton(
                title: L10n.GoalCreation.retryScheduling,
                icon: "arrow.clockwise",
                color: AppColors.accentBlue,
                onTap: retryScheduling
            )
            Button(
                L10n.GoalCreation.finishWithoutScheduling,
                action: onGoalScheduled
            )
            .font(AppFonts.subheadlineHeavy)
            .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
        .padding(24)
    }

    private func submitPrompt() {
        Task { await viewModel.submitCurrentPrompt() }
    }

    private func selectOption(_ option: String) {
        Task { await viewModel.selectOption(option) }
    }

    private func startRecording() {
        Task { await viewModel.beginRecording() }
    }

    private func finishRecording() {
        Task { await viewModel.finishRecording() }
    }

    private func confirmGoal() {
        Task { await viewModel.confirmProposal() }
    }

    private func confirmSchedule() {
        Task {
            if await viewModel.prepareScheduleConfirmation() {
                onGoalScheduled()
            }
        }
    }

    private func continueWithoutUnscheduledTasks() {
        Task {
            if await viewModel.continueWithoutUnscheduledTasks() {
                onGoalScheduled()
            }
        }
    }

    private func retryScheduling() {
        Task { await viewModel.retryScheduling() }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
}
