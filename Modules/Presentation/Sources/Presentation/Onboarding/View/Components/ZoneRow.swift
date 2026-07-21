//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import SwiftUI

struct ZoneRow: View {
    let zone: SuggestedZone

    private var dotColor: Color {
        Color(red: zone.colorRed, green: zone.colorGreen, blue: zone.colorBlue)
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)

                Text(zone.name)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(dotColor)
            }

            Spacer()

            Text("\(zone.startTime) – \(zone.endTime)")
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(dotColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 10) {
        ZoneRow(
            zone: SuggestedZone(
                id: UUID(),
                name: "Study",
                startTime: "7:00 AM",
                endTime: "9:30 AM",
                colorRed: 0.5, colorGreen: 0.0, colorBlue: 0.5
            )
        )
        ZoneRow(
            zone: SuggestedZone(
                id: UUID(),
                name: "Work",
                startTime: "9:30 AM",
                endTime: "1:00 PM",
                colorRed: 0.0, colorGreen: 0.0, colorBlue: 1.0
            )
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}
