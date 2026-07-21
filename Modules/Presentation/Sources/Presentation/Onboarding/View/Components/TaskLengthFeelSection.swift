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
            Text("HOW BLOCKS FEEL")
                .font(AppFonts.hourLabel)
                .foregroundColor(AppColors.textSecondary)
                .kerning(1.5)

            HStack(spacing: 12) {
                BlockFeelOptionView(
                    title: "30m", subtitle: "short & light", numberOfBlocks: 3,
                    isSelected: focusDurationIndex == 0
                )
                .onTapGesture { withAnimation { focusDurationIndex = 0 } }
                
                BlockFeelOptionView(
                    title: "1h", subtitle: "balanced", numberOfBlocks: 2,
                    isSelected: focusDurationIndex == 2
                )
                .onTapGesture { withAnimation { focusDurationIndex = 2 } }
                
                BlockFeelOptionView(
                    title: "3h", subtitle: "deep & few", numberOfBlocks: 1,
                    isSelected: focusDurationIndex == 5
                )
                .onTapGesture { withAnimation { focusDurationIndex = 5 } }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
}

//#Preview {
//    TaskLengthFeelSection()
//}
