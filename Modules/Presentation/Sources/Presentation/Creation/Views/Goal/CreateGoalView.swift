import Common
import SwiftUI

struct CreateGoalView: View {
    @State private var viewModel: CreateGoalViewModel

    init(viewModel: CreateGoalViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                starterContent

                QuickTaskComposer(
                    text: $bindableViewModel.prompt,
                    isRecording: viewModel.isRecording,
                    placeholder: L10n.GoalCreation.promptPlaceholder,
                    sendAccessibilityLabel: L10n.GoalCreation.sendPrompt,
                    recordingAccessibilityLabel: L10n.Home.tellAwan,
                    onSend: viewModel.submitCurrentPrompt,
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
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
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

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
}
