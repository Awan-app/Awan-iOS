//
//  DailyZonesCenterStack.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common
import Domain

struct DailyZonesCenterStack: View {
    let zones: [Zone]
    let isReady: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            DailyZonesTitleRow(isReady: isReady)

            Text(L10n.Profile.setRhythm)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)

            Text(L10n.Profile.zonesToday(zones.count))
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.accentBlue)

            if !zones.isEmpty {
                DailyZoneBarsView(zones: zones)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
