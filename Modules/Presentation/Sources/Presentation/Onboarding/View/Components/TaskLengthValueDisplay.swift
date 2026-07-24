//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 20/07/2026.
//

import SwiftUI
import Common

struct TaskLengthValueDisplay: View {
    let focusDurationText: String

    var body: some View {
        VStack(spacing: 8) {
            Text(focusDurationText)
                .font(AppFonts.nudgeSymbol)
                .foregroundColor(AppColors.brandDarkBlue)

            Text(L10n.Onboarding.preferredFocusBlock)
                .font(AppFonts.subheadlineBold)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, 10)
    }
}

//#Preview {
//    TaskLengthValueDisplay()
//}
