//
//  DailyZonesCard.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//
import SwiftUI
import Common
import Domain

// MARK: - DailyZonesCard

struct DailyZonesCard: View {
    let zones: [Zone]
    let isReady: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: L10n.Profile.dailyZones, accentColor: AppColors.accentPurple)

            DepthCardContainer {
                Button(action: onTap) {
                    DailyZonesCardRow(zones: zones, isReady: isReady)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews

private var mockZones: [Zone] {
    do {
        return [
            Zone(id: UUID(), name: "Work", color: try ZoneColor(hex: "#7459D9"), startTime: try LocalTime(hour: 9, minute: 0), endTime: try LocalTime(hour: 12, minute: 0)),
            Zone(id: UUID(), name: "Lunch", color: try ZoneColor(hex: "#3F8CFA"), startTime: try LocalTime(hour: 12, minute: 0), endTime: try LocalTime(hour: 13, minute: 0))
        ]
    } catch {
        return []
    }
}

#Preview("DailyZonesCard – Light") {
    DailyZonesCard(zones: mockZones, isReady: true, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.light)
}

#Preview("DailyZonesCard – Dark") {
    DailyZonesCard(zones: mockZones, isReady: true, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}

#Preview("DailyZonesCard – Empty") {
    DailyZonesCard(zones: [], isReady: false, onTap: {})
        .padding()
        .background(AppColors.screenBackground)
}
