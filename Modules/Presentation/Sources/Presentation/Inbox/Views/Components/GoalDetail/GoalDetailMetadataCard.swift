//
//  GoalDetailMetadataCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailMetadataCard: View {
    let createdAt: Date

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppColors.accentBlue)
                    Text(L10n.Goals.created)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(Self.dateFormatter.string(from: createdAt))
                        .font(AppFonts.subheadlineBold)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }
}
