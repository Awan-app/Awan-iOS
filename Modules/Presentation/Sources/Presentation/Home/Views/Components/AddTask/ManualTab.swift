import Common
import Domain
import SwiftUI

struct ManualTab: View {
    let zones: [Zone]
    let onSubmit: (String, String?, Int, UUID?, Bool, Bool, Date?) -> Void

    @Binding var title: String
    @Binding var description: String
    @Binding var durationMinutes: Int
    @Binding var selectedZoneID: UUID?
    @Binding var isMandatory: Bool
    @Binding var allowTaskSplitting: Bool
    @Binding var startsAt: Date

    @State private var useSpecificTime: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.Home.buildItYourWay)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)

            fieldCard(title: L10n.Schedule.questName.uppercased()) {
                TextField(L10n.Schedule.questNamePlaceholder, text: $title)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .textFieldStyle(.plain)
            }

            fieldCard(title: L10n.Home.fieldDescription.uppercased()) {
                TextField(L10n.Home.fieldDescriptionPlaceholder, text: $description)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .textFieldStyle(.plain)
            }

            fieldCard(title: L10n.Home.estimatedDuration) {
                HStack {
                    Text(durationText(durationMinutes))
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            if durationMinutes > 15 {
                                durationMinutes -= 15
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.accentBlue)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            if durationMinutes < 480 {
                                durationMinutes += 15
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(AppColors.accentBlue)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !zones.isEmpty {
                fieldCard(title: L10n.Schedule.zone.uppercased()) {
                    Menu {
                        Button(L10n.Schedule.standalone) { selectedZoneID = nil }
                        ForEach(zones) { zone in
                            Button(zone.name) { selectedZoneID = zone.id }
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(selectedZoneColor)
                                .frame(width: 12, height: 12)
                            Text(selectedZoneName)
                                .font(AppFonts.bodyBold)
                                .foregroundStyle(AppColors.brandDarkBlue)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }

            fieldCard(title: L10n.Home.fieldStartsAt.uppercased()) {
                VStack(spacing: 12) {
                    Toggle(isOn: $useSpecificTime.animation()) {
                        Text("Set specific time")
                            .font(AppFonts.bodyBold)
                            .foregroundStyle(AppColors.brandDarkBlue)
                    }
                    .tint(AppColors.accentBlue)

                    if useSpecificTime {
                        Divider()
                        HStack {
                            Text("Time")
                                .font(AppFonts.bodyBold)
                                .foregroundStyle(AppColors.brandDarkBlue)
                            
                            Spacer()
                            
                            DatePicker(
                                "",
                                selection: $startsAt,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .tint(AppColors.accentBlue)
                        }
                    }
                }
            }

            VStack(spacing: 14) {
                Toggle(isOn: $isMandatory) {
                    Text(L10n.Home.toggleMandatory)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)
                }
                .tint(AppColors.accentBlue)

                Divider()

                Toggle(isOn: $allowTaskSplitting) {
                    Text(L10n.Schedule.canSplit)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.brandDarkBlue)
                }
                .tint(AppColors.accentBlue)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppColors.accentBlue.opacity(0.05), radius: 6, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.accentBlue.opacity(0.15), lineWidth: 1)
            )

            AppButton(
                title: L10n.Home.btnAddManualTask,
                icon: nil,
                color: AppColors.accentBlue,
                onTap: submit
            )
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1.0)
        }
    }

    private func fieldCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColors.accentBlue.opacity(0.12), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.2), lineWidth: 1.5)
        )
    }

    private var selectedZoneName: String {
        guard let selectedZoneID else { return L10n.Schedule.standalone }
        return zones.first(where: { $0.id == selectedZoneID })?.name ?? L10n.Schedule.chooseZone
    }

    private var selectedZoneColor: Color {
        guard let id = selectedZoneID,
            let zone = zones.first(where: { $0.id == id })
        else { return AppColors.runtimeFallback }
        return AppColors.runtime(hex: zone.color.hex)
    }

    private func durationText(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let rem = minutes % 60
            return rem == 0 ? L10n.Home.hoursShort(hours) : L10n.Home.hoursMinutesShort(hours, rem)
        }
        return L10n.Home.minutesShort(minutes)
    }

    private func submit() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        let cleanDesc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        onSubmit(
            cleanTitle,
            cleanDesc.isEmpty ? nil : cleanDesc,
            durationMinutes,
            selectedZoneID,
            allowTaskSplitting,
            isMandatory,
            useSpecificTime ? startsAt : nil
        )
    }
}
