import Common
import SwiftUI

struct GoalCreatorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let zones: [TimelineZoneOption]
    let startDay: Date
    let onCreate: (String, UUID, Int) -> Void

    @State private var name = ""
    @State private var zoneID: UUID?
    @State private var durationMinutes = 45

    init(
        zones: [TimelineZoneOption],
        startDay: Date,
        onCreate: @escaping (String, UUID, Int) -> Void
    ) {
        self.zones = zones
        self.startDay = startDay
        self.onCreate = onCreate
        _zoneID = State(initialValue: zones.first(where: { $0.name == "Work" })?.id ?? zones.first?.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(AppFonts.goalHeroSymbol)
                            .foregroundStyle(AppColors.reward)
                            .symbolEffect(.wiggle, options: .repeat(2), value: durationMinutes)
                        Text(L10n.Schedule.buildQuestTitle)
                            .font(AppFonts.title2Black)
                        Text(L10n.Schedule.buildQuestSubtitle)
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    AppCard {
                        VStack(spacing: 18) {
                            TextField(L10n.Schedule.goalName, text: $name)
                                .font(AppFonts.bodySemibold)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityIdentifier("goal-name-field")
                            Stepper(value: $durationMinutes, in: 15...180, step: 15) {
                                HStack {
                                    Label(L10n.Schedule.eachStep, systemImage: "timer")
                                    Spacer()
                                    Text(L10n.Schedule.minutesScheduled(durationMinutes))
                                }
                                .font(AppFonts.bodyBold)
                            }
                            Menu {
                                ForEach(zones) { zone in
                                    Button(zone.name) { zoneID = zone.id }
                                }
                            } label: {
                                HStack {
                                    Label(selectedZone?.name ?? L10n.Schedule.chooseZone, systemImage: "square.3.layers.3d")
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .font(AppFonts.bodyBold)
                                .padding(12)
                                .background(
                                    AppColors.textPrimary.opacity(0.05),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .tint(AppColors.textPrimary)
                        }
                    }

                    sevenDayPreview

                    AppButton(
                        title: L10n.Schedule.startQuest,
                        icon: "flag.checkered",
                        color: AppColors.accentPurple,
                        onTap: {
                            guard let zoneID else { return }
                            let cleanName = name.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            guard !cleanName.isEmpty else { return }
                            onCreate(cleanName, zoneID, durationMinutes)
                            dismiss()
                        }
                    )
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || zoneID == nil)
                    .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    .accessibilityIdentifier("save-goal-button")
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .font(AppFonts.bodyBold)
                }
            }
        }
    }

    private var sevenDayPreview: some View {
        HStack(spacing: 7) {
            ForEach(0..<7, id: \.self) { index in
                let day = Calendar.current.date(byAdding: .day, value: index, to: startDay) ?? startDay
                VStack(spacing: 7) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(AppFonts.captionHeavy)
                    ZStack {
                        Circle().fill(AppColors.accentPurple.opacity(0.15))
                        Text("\(index + 1)")
                            .font(AppFonts.subheadlineBlack)
                            .foregroundStyle(AppColors.accentPurple)
                    }
                    .frame(width: 34, height: 34)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var selectedZone: TimelineZoneOption? {
        zones.first { $0.id == zoneID }
    }
}
