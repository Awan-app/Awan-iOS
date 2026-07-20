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
                Text("Clear skies!")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.brandDarkBlue)
                
                Text("Nothing scheduled yet. Add your first thing and I'll float it into the right zone.")
                    .font(AppFonts.captionHeavy)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            OnboardingContinueButton(
                title: "Add your first task",
                icon: "plus"
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
