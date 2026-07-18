//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 17/07/2026.
//

import Common
import SwiftUI

struct TypingDotsView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 4, height: 4)
                    .offset(y: isAnimating ? -3 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .foregroundColor(AppColors.accentBlue)
        .onAppear {
            isAnimating = true
        }
    }
}
