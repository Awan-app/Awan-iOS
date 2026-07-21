//
//  ProfileNameEmailView.swift
//  Presentation
//

import SwiftUI
import Common

struct ProfileNameEmailView: View {
    let name: String
    let email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Text(email)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
    }
}
