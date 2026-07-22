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
            Text("Daily zones")
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            if isReady {
                DailyZonesStatusBadge(title: "READY")
            }
        }
    }
}
