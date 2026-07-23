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
                .background(
                    AppColors.surface,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColors.accentBlue.opacity(0.40), lineWidth: 1.5)
                }
        }
        .buttonStyle(ProfileEditDepthButtonStyle())
    }
}

// MARK: - Depth-Press Button Style (mirrors AppButton's PressedDepthButtonStyle)

private struct ProfileEditDepthButtonStyle: ButtonStyle {
    private let shadowColor = AppColors.accentBlue.opacity(0.30)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: shadowColor, radius: 0, x: 0, y: configuration.isPressed ? 1 : 4)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}
