//
//  DailyZonesCard.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//
import SwiftUI
import Common

// MARK: - DailyZonesCard

struct DailyZonesCard: View {
    /// Colors for each zone — drives the ring segments, bars, and the
    /// "N zones today" count. Pass an empty array for a zero-state.
    let zoneColors: [Color]
    //if you do not need this attribute delete it and it write it manually
    let isReady: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: "DAILY ZONES", accentColor: AppColors.accentPurple)

            DepthCardContainer {
                Button(action: onTap) {
                    DailyZonesCardRow(zoneColors: zoneColors, isReady: isReady)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews

private let sampleColors: [Color] = [
    AppColors.accentPurple,
    AppColors.accentBlue,
    Color.orange,
    Color(red: 0.93, green: 0.26, blue: 0.26)
]

#Preview("DailyZonesCard – Light") {
    DailyZonesCard(zoneColors: sampleColors, isReady: true, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.light)
}

#Preview("DailyZonesCard – Dark") {
    DailyZonesCard(zoneColors: sampleColors, isReady: true, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}

#Preview("DailyZonesCard – Empty") {
    DailyZonesCard(zoneColors: [], isReady: false, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
}
