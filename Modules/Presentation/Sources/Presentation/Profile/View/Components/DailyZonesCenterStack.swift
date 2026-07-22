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

            Text("Set the rhythm for each day")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)

            Text("\(zones.count) zones today")
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
