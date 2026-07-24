//
//  PreferencesCard.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import Common
import SwiftUI

// MARK: - Preference Item Model

struct PreferenceItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let onTap: () -> Void
}

// MARK: - PreferencesCard

struct PreferencesCard: View {
    let preferences: [PreferenceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: L10n.Profile.preferences, accentColor: AppColors.brandDarkBlue)

            DepthCardContainer {
                VStack(spacing: 0) {
                    ForEach(Array(preferences.enumerated()), id: \.element.id) { index, item in
                        PreferenceRowView(
                            icon: item.icon,
                            title: item.title,
                            value: item.value,
                            onTap: item.onTap
                        )
                        .padding(.vertical, 6)

                        if index < preferences.count - 1 {
                            Rectangle()
                                .fill(AppColors.divider)
                                .frame(height: 1)
                                .padding(.leading, 38)
                                .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("PreferencesCard – Light") {
    PreferencesCard(preferences: [
        PreferenceItem(icon: "clock", title: "Session time", value: "60 min", onTap: {}),
        PreferenceItem(icon: "globe", title: "Time zone", value: "Cairo · GMT+3", onTap: {}),
        PreferenceItem(
            icon: "moon", title: "Sleep schedule", value: "11:00 PM – 7:00 AM", onTap: {}),
    ])
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("PreferencesCard – Dark") {
    PreferencesCard(preferences: [
        PreferenceItem(icon: "clock", title: "Session time", value: "60 min", onTap: {}),
        PreferenceItem(icon: "globe", title: "Time zone", value: "Cairo · GMT+3", onTap: {}),
        PreferenceItem(
            icon: "moon", title: "Sleep schedule", value: "11:00 PM – 7:00 AM", onTap: {}),
    ])
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
