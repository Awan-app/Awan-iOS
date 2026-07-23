//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import SwiftUI

struct TaskLength: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    let labels = ["30", "45", "60", "90", "120", "3h"]

    var focusDurationText: String {
        switch viewModel.focusDurationIndex {
        case 0: return L10n.Onboarding.aboutMinutes(30)
        case 1: return L10n.Onboarding.aboutMinutes(45)
        case 2: return L10n.Onboarding.aboutHours(1)
        case 3: return L10n.Onboarding.aboutHours(1.5)
        case 4: return L10n.Onboarding.aboutHours(2)
        case 5: return L10n.Onboarding.aboutHours(3)
        default: return L10n.Onboarding.aboutHours(1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
           // ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    TaskLengthTitleArea()
                    TaskLengthValueDisplay(focusDurationText: focusDurationText)
                    TaskLengthSlider(
                        focusDurationIndex: $viewModel.focusDurationIndex, labels: labels)
                    TaskLengthExplanation()
                    TaskLengthFeelSection(focusDurationIndex: $viewModel.focusDurationIndex)
                }
                .padding(.bottom, 24)
            //}

            // 3. Floating Bottom Action Area Layer
            VStack {
                AppButton(
                    title: L10n.Common.continue,
                    icon: nil,
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    size: .large,
                    onTap: { onContinue() }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                Button(action: { onContinue() }) {
                    HStack(spacing: 4) {
                        Text(L10n.Onboarding.skipForNow)
                        Image(systemName: "arrow.right")
                    }
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundColor(AppColors.accentBlue)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct TaskLengthExplanation: View {
    var body: some View {
        (Text(L10n.Onboarding.taskLengthExplanationPrefix)
        .font(AppFonts.captionHeavy)
        .foregroundColor(AppColors.textSecondary)
            + Text(L10n.Onboarding.splitIntoSessions)
            .font(AppFonts.captionHeavy)
            .foregroundColor(AppColors.brandDarkBlue))
            .lineSpacing(4)
    }
}

#Preview {
    TaskLength(viewModel: .preview, onContinue: {})
}
