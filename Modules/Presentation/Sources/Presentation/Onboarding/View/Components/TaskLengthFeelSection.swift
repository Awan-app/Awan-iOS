//
//  SwiftUIView 2.swift
//  Presentation
//
//  Created by AndrewMagdy on 20/07/2026.
//

import SwiftUI
import Common

struct TaskLengthFeelSection: View {
    @Binding var focusDurationIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Onboarding.howBlocksFeel)
                .font(AppFonts.hourLabel)
                .foregroundColor(AppColors.textSecondary)
                .kerning(1.5)

            HStack(spacing: 12) {
                BlockFeelOptionView(
                    title: "30m", subtitle: L10n.Onboarding.feelShortLight, numberOfBlocks: 3,
                    isSelected: focusDurationIndex == 4
                )
                .onTapGesture { withAnimation { focusDurationIndex = 4 } }
                
                BlockFeelOptionView(
                    title: "1h", subtitle: L10n.Onboarding.feelBalanced, numberOfBlocks: 2,
                    isSelected: focusDurationIndex == 10
                )
                .onTapGesture { withAnimation { focusDurationIndex = 10 } }
                
                BlockFeelOptionView(
                    title: "3h", subtitle: L10n.Onboarding.feelDeepFew, numberOfBlocks: 1,
                    isSelected: focusDurationIndex == 16
                )
                .onTapGesture { withAnimation { focusDurationIndex = 16 } }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}

#Preview {
    TaskLengthFeelSection(focusDurationIndex: .constant(2))
}


#Preview {
    TaskLengthFeelSection(focusDurationIndex: .constant(0))
        .padding()
}

