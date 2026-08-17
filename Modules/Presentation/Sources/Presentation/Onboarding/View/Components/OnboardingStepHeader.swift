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
                    AppBackButton(
                        accessibilityLabel: L10n.CalendarScreen.back,
                        onTap: onBack
                    )
                } else {
                    Color.clear.frame(width: 40, height: 40)
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
