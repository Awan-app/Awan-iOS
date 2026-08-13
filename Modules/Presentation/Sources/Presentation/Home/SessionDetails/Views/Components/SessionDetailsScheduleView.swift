import Common
import SwiftUI

struct SessionDetailsScheduleView: View {
    let start: Date
    let end: Date
    let durationMinutes: Int?
    let selectedDurationMinutes: Int?
    let validationMessage: String?
    let isEnabled: Bool
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
            depthOffset: 5
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
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
                            Text(L10n.Home.minutesShort(minutes))
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

            HStack(spacing: 6) {
                Button {
                    onAdjust(-15)
                } label: {
                    Image(systemName: "minus")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.16),
                        depthColor: AppColors.outline.opacity(0.18),
                        depthOffset: 3
                    )
                )

                AppDepthSurface(
                    shape: .roundedRectangle(cornerRadius: 10),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.accentBlue.opacity(0.42),
                    depthColor: AppColors.accentBlueDepth.opacity(0.32),
                    borderWidth: 1.5,
                    depthOffset: 3,
                    contentInsets: EdgeInsets(
                        top: 2,
                        leading: 4,
                        bottom: 2,
                        trailing: 4
                    )
                ) {
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
                }

                Button {
                    onAdjust(15)
                } label: {
                    Image(systemName: "plus")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 32, height: 32)
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
