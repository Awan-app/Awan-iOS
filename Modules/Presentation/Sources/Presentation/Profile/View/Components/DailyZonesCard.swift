//
//  DailyZonesCard.swift
//  Presentation
//

import SwiftUI
import Common

// MARK: - DailyZonesCard

struct DailyZonesCard: View {
    /// Colors for each zone — drives the ring segments, bars, and the
    /// "N zones today" count. Pass an empty array for a zero-state.
    let zoneColors: [Color]
    let isReady: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: "DAILY ZONES", accentColor: AppColors.accentPurple)

            DepthCardContainer {
                Button(action: onTap) {
                    cardRow
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Card Row

    private var cardRow: some View {
        HStack(spacing: 14) {
            DailyZonesRingIcon(colors: zoneColors)

            centerStack

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Centre Stack

    private var centerStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleRow

            Text("Set the rhythm for each day")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)

            Text("\(zoneColors.count) zones today")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.accentBlue)

            if !zoneColors.isEmpty {
                DailyZoneBarsView(colors: zoneColors)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Title Row

    private var titleRow: some View {
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
