import Common
import Domain
import SwiftUI

struct ManualScheduleControls: View {
    let zones: [Zone]

    @Binding var startsAt: Date
    @Binding var durationMinutes: Int
    @Binding var selectedZoneID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            controlRow(
                icon: "clock.fill",
                title: L10n.Home.fieldStartsAt
            ) {
                DatePicker(
                    "",
                    selection: $startsAt,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .tint(AppColors.accentBlue)
            }

            Divider()
                .overlay(AppColors.accentBlue.opacity(0.14))
                .padding(.leading, 46)

            controlRow(
                icon: "hourglass",
                title: L10n.Home.estimatedDuration
            ) {
                HStack(spacing: 10) {
                    stepButton(icon: "minus") {
                        durationMinutes = max(15, durationMinutes - 15)
                    }

                    Text(durationText)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)

                    stepButton(icon: "plus") {
                        durationMinutes = min(480, durationMinutes + 15)
                    }
                }
            }

            if !zones.isEmpty {
                Divider()
                    .overlay(AppColors.accentBlue.opacity(0.14))
                    .padding(.leading, 46)

                controlRow(
                    icon: "square.grid.2x2.fill",
                    title: L10n.Schedule.zone
                ) {
                    Menu {
                        Button {
                            selectedZoneID = nil
                        } label: {
                            Label {
                                Text(L10n.Schedule.standalone)
                            } icon: {
                                Image(systemName: "circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(AppColors.runtimeFallback)
                            }
                        }
                        ForEach(zones) { zone in
                            Button {
                                selectedZoneID = zone.id
                            } label: {
                                Label {
                                    Text(zone.name)
                                } icon: {
                                    Image(systemName: "circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(
                                            AppColors.runtime(hex: zone.color.hex)
                                        )
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Circle()
                                .fill(selectedZoneColor)
                                .frame(width: 10, height: 10)

                            Text(selectedZoneName)
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.brandDarkBlue)
                                .lineLimit(1)

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.accentBlueDepth.opacity(0.45))
                    .offset(y: 5)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.surface)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1.5)
        }
        .padding(.bottom, 5)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func controlRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 34, height: 34)
                .background(AppColors.infoSurface, in: Circle())

            Text(title)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.brandDarkBlue)

            Spacer(minLength: 8)

            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func stepButton(
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 28, height: 28)
                .background(AppColors.infoSurface, in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.accentBlue.opacity(0.24), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var durationText: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            return minutes == 0
                ? L10n.Home.hoursShort(hours)
                : L10n.Home.hoursMinutesShort(hours, minutes)
        }
        return L10n.Home.minutesShort(durationMinutes)
    }

    private var selectedZoneName: String {
        guard let selectedZoneID else {
            return L10n.Schedule.standalone
        }
        return zones.first(where: { $0.id == selectedZoneID })?.name
            ?? L10n.Schedule.chooseZone
    }

    private var selectedZoneColor: Color {
        guard let selectedZoneID,
              let zone = zones.first(where: { $0.id == selectedZoneID })
        else {
            return AppColors.runtimeFallback
        }
        return AppColors.runtime(hex: zone.color.hex)
    }
}
