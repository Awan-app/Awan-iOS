import SwiftUI
import Common

struct DailyZonesCardRow: View {
    let zoneColors: [Color]
    let isReady: Bool

    var body: some View {
        HStack(spacing: 14) {
            DailyZonesRingIcon(colors: zoneColors)

            DailyZonesCenterStack(zoneColors: zoneColors, isReady: isReady)

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
