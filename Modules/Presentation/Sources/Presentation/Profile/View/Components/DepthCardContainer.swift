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
        ZStack(alignment: .bottom) {
            // Shelf / depth layer
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.accentBlue.opacity(0.20))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 2)

            // Surface layer — floats 5 pt above the shelf
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    AppColors.surface,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppColors.outline.opacity(0.10), lineWidth: 1.5)
                }
                .padding(.bottom, 5)
        }
    }
}
