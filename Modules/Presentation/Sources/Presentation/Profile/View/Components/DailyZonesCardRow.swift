import SwiftUI
import Common

import Domain

struct DailyZonesCardRow: View {
    let zones: [Zone]
    let isReady: Bool

    var body: some View {
        HStack(spacing: 14) {
            DailyZonesRingIcon(zones: zones)

            DailyZonesCenterStack(zones: zones, isReady: isReady)

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
