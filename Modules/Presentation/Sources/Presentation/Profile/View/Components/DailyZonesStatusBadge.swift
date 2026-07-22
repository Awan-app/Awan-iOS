//
//  DailyZonesStatusBadge.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

/// Small pill badge (e.g. "READY") used in the DailyZonesCard header row.
struct DailyZonesStatusBadge: View {
    let title: String
    var color: Color = AppColors.accentGreen

    var body: some View {
        Text(title)
            .font(AppFonts.caption2Bold)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay {
                Capsule()
                    .stroke(color, lineWidth: 1.5)
            }
    }
}
