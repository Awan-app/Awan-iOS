//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import SwiftUI

struct TaskLength: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel

    let labels = ["30", "45", "60", "90", "120", "3h"]

    var focusDurationText: String {
        switch viewModel.focusDurationIndex {
        case 0: return "About 30 minutes"
        case 1: return "About 45 minutes"
        case 2: return "About 1 hour"
        case 3: return "About 1.5 hours"
        case 4: return "About 2 hours"
        case 5: return "About 3 hours"
        default: return "About 1 hour"
        }
    }

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
                OnboardingStepHeader(
                    currentStep: 4,
                    totalSteps: viewModel.totalSteps,
                    onSkip: { viewModel.skipOnboarding() }
                )
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        TaskLengthTitleArea()
                        TaskLengthValueDisplay(focusDurationText: focusDurationText)
                        TaskLengthSlider(focusDurationIndex: $viewModel.focusDurationIndex, labels: labels)
                        TaskLengthExplanation()
                        TaskLengthFeelSection(focusDurationIndex: $viewModel.focusDurationIndex)
                    }
                    .padding(.bottom, 140)
                }
            }

            // 3. Floating Bottom Action Area Layer
            VStack {
                Spacer()

                AppButton(
                    title: "CONTINUE",
                    icon: nil,
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    size: .large,
                    onTap: { appCoordinator.onboardingCoordinator.push(.taskSimulation) }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .background(Color.clear)
            }
        }
    }
}

private struct TaskLengthExplanation: View {
    var body: some View {
        (Text(
            "Longer means fewer, deeper blocks; shorter means\nmore, lighter ones. Anything longer gets "
        )
        .font(AppFonts.captionHeavy)
        .foregroundColor(AppColors.textSecondary)
            + Text("split into\nlinked sessions.")
            .font(AppFonts.captionHeavy)
            .foregroundColor(AppColors.brandDarkBlue))
            .lineSpacing(4)
    }
}

#Preview {
    TaskLength(viewModel: .preview)
        .environment(AppCoordinator())
}
