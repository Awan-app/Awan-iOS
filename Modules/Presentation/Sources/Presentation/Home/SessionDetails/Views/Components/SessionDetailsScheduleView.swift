import Common
import SwiftUI

struct SessionDetailsScheduleView: View {
    let selectedDay: Date
    let start: Date
    let end: Date
    let durationMinutes: Int?
    let selectedDurationMinutes: Int?
    let validationMessage: String?
    let isEnabled: Bool
    let onDayChange: (Date) -> Void
    let onStartChange: (Date) -> Void
    let onEndChange: (Date) -> Void
    let onAdjustStart: (Int) -> Void
    let onAdjustEnd: (Int) -> Void
    let onSelectDuration: (Int) -> Void

    private let durations = [15, 30, 45, 60, 90, 120]

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.18),
            depthColor: AppColors.accentBlueDepth.opacity(0.32),
            depthOffset: 5,
            contentInsets: EdgeInsets(
                top: 18,
                leading: 14,
                bottom: 18,
                trailing: 14
            )
        ) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.Home.sessionDay)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    AppDatePickerField(
                        selection: Binding(
                            get: { selectedDay },
                            set: { newValue in onDayChange(newValue) }
                        ),
                        title: L10n.Home.sessionDay,
                        in: Date.distantPast...Date.distantFuture
                    )
                    .disabled(!isEnabled)
                }

                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 8) {
                    SessionDetailsTimeControl(
                        title: L10n.Home.startTime,
                        selection: start,
                        isEnabled: isEnabled,
                        onChange: onStartChange,
                        onAdjust: onAdjustStart
                    )

                    SessionDetailsTimeControl(
                        title: L10n.Home.endTime,
                        selection: end,
                        isEnabled: isEnabled,
                        onChange: onEndChange,
                        onAdjust: onAdjustEnd
                    )
                }

                if let validationMessage {
                    Label(
                        validationMessage,
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.destructive)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Text(L10n.Home.duration)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    if let durationMinutes {
                        Text(L10n.Home.minutesShort(durationMinutes))
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(durations, id: \.self) { minutes in
                        Button {
                            onSelectDuration(minutes)
                        } label: {
                            Text(String(minutes))
                                .font(AppFonts.captionHeavy)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .foregroundStyle(
                                    selectedDurationMinutes == minutes
                                        ? AppColors.onAccent
                                        : AppColors.textPrimary
                                )
                                .frame(maxWidth: .infinity, minHeight: 38)
                        }
                        .buttonStyle(
                            AppDepthButtonStyle(
                                shape: .roundedRectangle(cornerRadius: 12),
                                surfaceColor: selectedDurationMinutes == minutes
                                    ? AppColors.accentBlue
                                    : AppColors.surface,
                                borderColor: selectedDurationMinutes == minutes
                                    ? AppColors.accentBlue
                                    : AppColors.outline.opacity(0.16),
                                depthColor: selectedDurationMinutes == minutes
                                    ? AppColors.accentBlueDepth
                                    : AppColors.outline.opacity(0.16),
                                depthOffset: 3
                            )
                        )
                        .disabled(!isEnabled)
                        .accessibilityAddTraits(
                            selectedDurationMinutes == minutes ? .isSelected : []
                        )
                    }
                }
            }
        }
    }
}

private struct SessionDetailsTimeControl: View {
    let title: String
    let selection: Date
    let isEnabled: Bool
    let onChange: (Date) -> Void
    let onAdjust: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: 12) {
                Button {
                    onAdjust(-15)
                } label: {
                    Image(systemName: "minus")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.16),
                        depthColor: AppColors.outline.opacity(0.18),
                        depthOffset: 3
                    )
                )

                DatePicker(
                    title,
                    selection: Binding(
                        get: { selection },
                        set: { newValue in onChange(newValue) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(AppColors.accentBlue)
                .font(AppFonts.captionHeavy)
                .frame(width: 78)

                Button {
                    onAdjust(15)
                } label: {
                    Image(systemName: "plus")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.16),
                        depthColor: AppColors.outline.opacity(0.18),
                        depthOffset: 3
                    )
                )
            }
            .disabled(!isEnabled)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)
    }
}
