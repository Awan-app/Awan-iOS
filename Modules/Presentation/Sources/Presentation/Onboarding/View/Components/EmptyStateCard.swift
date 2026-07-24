//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import SwiftUI
import Common

struct EmptyStateCard: View {
    let onAddFirstTask: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            AuthCloudLogoView()
            
            VStack(spacing: 8) {
                Text(L10n.Onboarding.clearSkies)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.brandDarkBlue)
                
                Text(L10n.Onboarding.nothingScheduled)
                    .font(AppFonts.captionHeavy)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            OnboardingContinueButton(
                title: L10n.Onboarding.addFirstTask
                //icon: "plus"
            ) {
                onAddFirstTask()
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                .foregroundColor(AppColors.outline)
        )
    }
}

#Preview {
    EmptyStateCard(onAddFirstTask: {})
        .padding()
        .background(AppColors.screenBackground)
}
