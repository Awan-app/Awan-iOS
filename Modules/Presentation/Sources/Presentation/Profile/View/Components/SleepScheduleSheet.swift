import Common
import Domain
import SwiftUI

struct SleepScheduleSheet: View {
    let initialWakeUpTime: LocalTime?
    let initialSleepTime: LocalTime?
    let onSave: (_ wakeUpTime: String, _ sleepTime: String) -> Void
    let onDismiss: () -> Void

    @State private var wakeUpDate: Date
    @State private var sleepDate: Date

    init(
        initialWakeUpTime: LocalTime?,
        initialSleepTime: LocalTime?,
        onSave: @escaping (_ wakeUpTime: String, _ sleepTime: String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialWakeUpTime = initialWakeUpTime
        self.initialSleepTime = initialSleepTime
        self.onSave = onSave
        self.onDismiss = onDismiss

        _wakeUpDate = State(initialValue: Self.dateFromLocalTime(initialWakeUpTime, defaultHour: 7, defaultMinute: 0))
        _sleepDate = State(initialValue: Self.dateFromLocalTime(initialSleepTime, defaultHour: 23, defaultMinute: 0))
    }

    private static func dateFromLocalTime(_ localTime: LocalTime?, defaultHour: Int, defaultMinute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = localTime?.hour ?? defaultHour
        components.minute = localTime?.minute ?? defaultMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    private func formatTime(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return String(format: "%02d:%02d:00", hour, minute)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header bar
            HStack {
                Text(L10n.Profile.sleepSchedule)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.brandDarkBlue)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            // Time Pickers Container using AppCard
            AppCard {
                VStack(spacing: 16) {
                    // Wake Up Row
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.accentBlue)

                        Text(L10n.Onboarding.wakeLabel)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        DatePicker(
                            "",
                            selection: $wakeUpDate,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(AppColors.accentBlue)
                    }
                    .padding(.vertical, 4)

                    Divider()
                        .background(AppColors.divider)

                    // Sleep Row
                    HStack {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.accentBlue)

                        Text(L10n.Onboarding.sleepLabel)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        DatePicker(
                            "",
                            selection: $sleepDate,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(AppColors.accentBlue)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 4)
            }

            Spacer()

            // 3D Save Button using AppButton
            AppButton(
                title: L10n.Common.save,
                icon: "checkmark.circle.fill",
                color: AppColors.accentBlue,
                size: .large,
                onTap: {
                    onSave(formatTime(wakeUpDate), formatTime(sleepDate))
                }
            )
        }
        .padding(20)
        .background(AppColors.screenBackground.ignoresSafeArea())
    }
}

#if DEBUG
#Preview {
    SleepScheduleSheet(
        initialWakeUpTime: try? LocalTime(hour: 7, minute: 0),
        initialSleepTime: try? LocalTime(hour: 23, minute: 0),
        onSave: { _, _ in },
        onDismiss: {}
    )
}
#endif
