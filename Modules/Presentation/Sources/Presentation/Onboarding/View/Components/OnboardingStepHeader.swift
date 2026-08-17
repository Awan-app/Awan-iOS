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
                    AppButton(
                        title: "",
                        icon: "arrow.backward",
                        color: AppColors.surface,
                        foregroundColor: AppColors.brandDarkBlue,
                        borderColor: AppColors.outline.opacity(0.12),
                        size: .compact,
                        expandsHorizontally: false,
                        useGradient: false,
                        onTap: { onBack() }
                    )
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
                
                Spacer()
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


#Preview {
    OnboardingStepHeader(currentStep: 1, totalSteps: 4, onSkip: {}, onBack: {})
        .padding()
}

