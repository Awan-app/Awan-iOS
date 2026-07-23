//
//  DailyZonesTitleRow.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct DailyZonesTitleRow: View {
    let isReady: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(L10n.Profile.dailyZones)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            if isReady {
                DailyZonesStatusBadge(title: L10n.Profile.ready)
            }
        }
    }
}
