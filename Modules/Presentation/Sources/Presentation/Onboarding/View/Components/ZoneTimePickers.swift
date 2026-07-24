import SwiftUI
import Common

struct ZoneTimePickers: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    let isHorizontal: Bool
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isHorizontal {
                HStack(spacing: 16) {
                    startPicker
                        .frame(maxWidth: .infinity, alignment: .leading)
                    endPicker
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                startPicker
                endPicker
            }

            if startTime >= endTime {
                Label("End time must be after start time", systemImage: "exclamationmark.triangle.fill")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.destructive)
            }
        }
    }

    private var startPicker: some View {
        ZoneLabeledField(L10n.Onboarding.zoneStartTime, icon: "clock") {
            DatePicker(
                "",
                selection: $startTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .onChange(of: startTime) { onChange() }
            .accessibilityIdentifier("zone-start-picker")
        }
    }

    private var endPicker: some View {
        ZoneLabeledField(L10n.Onboarding.zoneEndTime, icon: "clock.badge.checkmark") {
            DatePicker(
                "",
                selection: $endTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .onChange(of: endTime) { onChange() }
            .accessibilityIdentifier("zone-end-picker")
        }
    }
}
