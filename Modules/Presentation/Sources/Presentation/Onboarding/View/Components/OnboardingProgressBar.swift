import SwiftUI
import Common

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    init(currentStep: Int, totalSteps: Int = 6) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index < currentStep ? AppColors.accentBlue : AppColors.accentBlue.opacity(0.1))
                    .frame(height: 6)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            OnboardingProgressBar(currentStep: 4)
            OnboardingProgressBar(currentStep: 6)
        }
        .padding()
    }
}
