//
//  OnboardingProgressBar.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index < currentStep ? AppColors.accentBlue : AppColors.divider)
                    .frame(height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 6)
        OnboardingProgressBar(currentStep: 3, totalSteps: 6)
        OnboardingProgressBar(currentStep: 6, totalSteps: 6)
    }
    .padding()
}
