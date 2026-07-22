//
//  DepthCardContainer.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//
import SwiftUI
import Common

/// A Duolingo-style 3D card container — a coloured shelf sits behind a
/// raised white surface, giving a tactile depth effect that mirrors the
/// `PressedDepthButtonStyle` used in `AppButton`.
struct DepthCardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background {
                // Surface background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.surface)

                // Depth/shelf layer — same shape as card, shifted down slightly
                // so it only peeks out at the bottom edge
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.18))
                    .padding(.horizontal, 2)
                    .offset(y: 5)
                    .zIndex(-1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.10), lineWidth: 1.5)
            }
            .padding(.bottom, 5) // Reserve space so the shelf peek-out isn't clipped
    }
}
