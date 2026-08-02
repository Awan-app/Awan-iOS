//
//  ProfileEditButton.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct ProfileEditButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Label(L10n.Common.edit, systemImage: "pencil")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 14),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.accentBlue.opacity(0.40),
                depthColor: AppColors.accentBlueDepth,
                borderWidth: 1.5,
                depthOffset: 4,
                pressedOffset: 3
            )
        )
    }
}

#Preview {
    ProfileEditButton(onTap: {})
        .padding()
}
