//
//  SectionHeaderLabel.swift
//  Presentation
//

import SwiftUI
import Common

struct SectionHeaderLabel: View {
    let title: String
    var accentColor: Color = AppColors.accentBlue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(accentColor)
                .padding(.leading, 4)

            Rectangle()
                .fill(accentColor)
                .frame(width: 36, height: 2.5)
                .clipShape(Capsule())
                .padding(.leading, 4)
        }
    }
}
