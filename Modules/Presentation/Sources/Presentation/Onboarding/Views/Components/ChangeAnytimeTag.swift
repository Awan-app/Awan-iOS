//
//  ChangeAnytimeTag.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct ChangeAnytimeTag: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .bold))
            Text("You can change this anytime")
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.accentBlue)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            AppColors.accentBlue.opacity(0.1),
            in: Capsule()
        )
    }
}

#Preview {
    ChangeAnytimeTag()
        .padding()
}
