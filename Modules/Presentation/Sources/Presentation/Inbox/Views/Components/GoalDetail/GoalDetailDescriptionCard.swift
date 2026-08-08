//
//  GoalDetailDescriptionCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailDescriptionCard: View {
    let description: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Home.description)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                Text(description)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
