//
//  OnboardingStepHeader.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct OnboardingStepHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()

                Button(action: onSkip) {
                    Text(L10n.Onboarding.skip)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                }
            }

            OnboardingProgressBar(currentStep: currentStep, totalSteps: totalSteps)
        }
    }
}

#Preview {
    OnboardingStepHeader(
        currentStep: 1,
        totalSteps: 6,
        onSkip: {}
    )
    .padding()
}
