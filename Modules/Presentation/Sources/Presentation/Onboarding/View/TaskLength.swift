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
                    title: "CONTINUE",
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
                        Text("Skip for now")
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
    TaskLength(viewModel: .preview, onContinue: {})
}
