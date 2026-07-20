import Common
import SwiftUI
import UIKit

struct TaskSimulation: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // 1. Background Layer
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 2. Scrollable Content Layer
            VStack(spacing: 0) {
                // Top Bar progress
                OnboardingStepHeader(
                    currentStep: 5,
                    totalSteps: viewModel.totalSteps,
                    onSkip: { viewModel.skipOnboarding() }
                )
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        VStack(spacing: 16) {
                            AuthCloudLogoView()

                            VStack(spacing: 8) {
                                Text("Let's add your first thing for today")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(AppColors.brandDarkBlue)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.top, 40)

                        if viewModel.addedTasks.isEmpty {
                            // Input Section
                            VStack(alignment: .leading, spacing: 8) {

                                Text("Try \"Go for a run\", \"Call Mum\", or \"Reading book\".")
                                    .font(AppFonts.captionHeavy)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 16)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppColors.accentBlueDepth.opacity(0.10))
                                        .padding(.horizontal, -4)
                                        .padding(.top, -4)
                                        .padding(.bottom, -8)

                                    TextField("e.g. Go for a run", text: $viewModel.taskText)
                                        .font(AppFonts.bodyBold)
                                        .foregroundColor(AppColors.brandDarkBlue)
                                        .padding(16)
                                        .background(AppColors.surface)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(
                                                    AppColors.accentBlue, lineWidth: isFocused ? 3 : 1)
                                        )
                                        .focused($isFocused)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                        } else {
                            TaskPreviewCard(
                                tasks: viewModel.addedTasks,
                                onDelete: { taskToDelete in
                                    viewModel.addedTasks.removeAll(where: { $0.id == taskToDelete.id })
                                }
                            )
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 24)
                }

                // 3. Bottom Action Area
                VStack(spacing: 8) {
                    if viewModel.addedTasks.isEmpty {
                        AppButton(
                            title: "ADD IT",
                            icon: nil,
                            color: AppColors.accentBlue,
                            foregroundColor: AppColors.onAccent,
                            size: .large,
                            onTap: {
                                let trimmed = viewModel.taskText.trimmingCharacters(
                                    in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        viewModel.addedTasks.append(TaskItem(title: trimmed))
                                        viewModel.taskText = ""
                                    }
                                }
                            }
                        )
                        .disabled(
                            viewModel.taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                        .opacity(
                            viewModel.taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? 0.5 : 1.0)

                        Button(action: { appCoordinator.onboardingCoordinator.push(.notification) }) {
                            HStack(spacing: 4) {
                                Text("Skip for now")
                                Image(systemName: "arrow.right")
                            }
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundColor(AppColors.accentBlue)
                        }
                        .padding(.vertical, 8)
                    } else {
                        AppButton(
                            title: "CONTINUE",
                            icon: nil,
                            color: AppColors.accentBlue,
                            foregroundColor: AppColors.onAccent,
                            size: .large,
                            onTap: {
                                appCoordinator.onboardingCoordinator.push(.notification)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    //TaskSimulation()
}
