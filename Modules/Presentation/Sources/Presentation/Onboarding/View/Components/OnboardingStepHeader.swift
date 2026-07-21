//
//  OnboardingStepHeader.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

struct OnboardingStepHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onSkip: () -> Void
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.brandDarkBlue)
                    }
                } else {
                    Color.clear.frame(width: 24, height: 24)
                }
                
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
