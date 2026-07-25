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

        Group {
            switch viewModel.phase {
            case .starter:
                starterView(text: $bindableViewModel.prompt)
            case .loading:
                GoalCreationLoadingView(
                    message: L10n.GoalCreation.planning
                )
            case .conversation(let blocks):
                conversationView(
                    blocks: blocks,
                    text: $bindableViewModel.prompt
                )
            case .proposal(let narration, let goal):
                GoalProposalView(
                    narration: narration,
                    proposal: goal,
                    prompt: $bindableViewModel.prompt,
                    isRecording: viewModel.isRecording,
                    onSend: submitPrompt,
                    onOptionSelected: selectOption,
                    onRecordingStarted: startRecording,
                    onRecordingEnded: finishRecording,
                    onConfirm: confirmGoal
                )
            case .confirming:
                GoalCreationLoadingView(
                    message: L10n.GoalCreation.scheduling
                )
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .onChange(of: viewModel.requiresFullScreen, initial: true) { _, isFullScreen in
            onFullScreenChanged(isFullScreen)
        }
        .onDisappear {
            viewModel.cancelRecording()
        }
        .alert(L10n.Home.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private func starterView(text: Binding<String>) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                starterContent
                composer(
                    text: text,
                    placeholder: L10n.GoalCreation.promptPlaceholder
                )
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

            composer(
                text: text,
                placeholder: L10n.GoalCreation.replyPlaceholder
            )
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
            isRecording: viewModel.isRecording,
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

    private func submitPrompt() {
        Task {
            await viewModel.submitCurrentPrompt()
        }
    }

    private func selectOption(_ option: String) {
        Task {
            await viewModel.selectOption(option)
        }
    }

    private func startRecording() {
        Task {
            await viewModel.beginRecording()
        }
    }

    private func finishRecording() {
        Task {
            await viewModel.finishRecording()
        }
    }

    private func confirmGoal() {
        Task {
            if await viewModel.confirmProposal() {
                onGoalScheduled()
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
}
