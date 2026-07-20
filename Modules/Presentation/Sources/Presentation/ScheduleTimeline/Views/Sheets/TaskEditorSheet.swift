import Common
import SwiftUI

struct TaskEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let task: TimelineTaskEditorModel?
    let zones: [TimelineZoneOption]
    let selectedDay: Date
    let onSave: (String, Int, UUID?, Bool, Bool) -> Void
    let onDelete: (() -> Void)?

    @State private var title: String
    @State private var durationMinutes: Int
    @State private var zoneID: UUID?
    @State private var isSplittable: Bool
    @State private var blocking: Bool

    init(
        task: TimelineTaskEditorModel?,
        zones: [TimelineZoneOption],
        selectedDay: Date,
        onSave: @escaping (String, Int, UUID?, Bool, Bool) -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.task = task
        self.zones = zones
        self.selectedDay = selectedDay
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: task?.title ?? "")
        _durationMinutes = State(initialValue: task?.durationMinutes ?? 60)
        _zoneID = State(initialValue: task?.zoneID ?? zones.first?.id)
        _isSplittable = State(initialValue: task?.isSplittable ?? true)
        _blocking = State(initialValue: task?.blocking ?? false)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    mascotHeader
                    AppCard {
                        VStack(alignment: .leading, spacing: 18) {
                            labeledField(L10n.Schedule.questName, icon: "pencil.line") {
                                TextField(L10n.Schedule.questNamePlaceholder, text: $title)
                                    .font(AppFonts.bodySemibold)
                                    .textFieldStyle(.roundedBorder)
                                    .accessibilityIdentifier("task-title-field")
                            }
                            labeledField(L10n.Schedule.duration, icon: "timer") {
                                Stepper(value: $durationMinutes, in: 15...480, step: 15) {
                                    Text(L10n.Schedule.durationMinutes(durationMinutes))
                                        .font(AppFonts.bodyBold)
                                }
                                .accessibilityIdentifier("task-duration-stepper")
                            }
                            labeledField(L10n.Schedule.zone, icon: "square.3.layers.3d") {
                                Menu {
                                    Button(L10n.Schedule.standalone) { zoneID = nil }
                                    ForEach(zones) { zone in
                                        Button(zone.name) { zoneID = zone.id }
                                    }
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(selectedZoneColor)
                                            .frame(width: 13, height: 13)
                                        Text(selectedZoneName)
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
                                .accessibilityIdentifier("task-zone-menu")
                            }
                            Toggle(isOn: $isSplittable) {
                                Label(L10n.Schedule.canSplit, systemImage: "rectangle.split.2x1")
                                    .font(AppFonts.bodyBold)
                            }
                            .tint(AppColors.accentGreen)
                            if task != nil {
                                Toggle(isOn: $blocking) {
                                    Label(
                                        L10n.Schedule.keepFixed,
                                        systemImage: "lock.fill"
                                    )
                                    .font(AppFonts.bodyBold)
                                }
                                .tint(AppColors.warning)
                                .accessibilityIdentifier("task-blocking-toggle")
                            }
                        }
                    }

                    AppButton(
                        title: task == nil ? L10n.Schedule.createQuest : L10n.Schedule.saveChanges,
                        icon: task == nil ? "sparkles" : "checkmark.seal.fill",
                        color: AppColors.accentGreen,
                        onTap: {
                            let cleanTitle = title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            guard !cleanTitle.isEmpty else { return }
                            onSave(
                                cleanTitle,
                                durationMinutes,
                                zoneID,
                                isSplittable,
                                blocking
                            )
                            dismiss()
                        }
                    )
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    .accessibilityIdentifier("save-task-button")

                    if let onDelete {
                        AppButton(
                            title: L10n.Schedule.deleteQuest,
                            icon: "trash.fill",
                            color: AppColors.destructive,
                            onTap: {
                                onDelete()
                                dismiss()
                            }
                        )
                    }
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

    private var mascotHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: task == nil ? "star.bubble.fill" : "pencil.and.scribble")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(
                    task == nil ? AppColors.accentPurple : AppColors.accentBlue
                )
                .symbolEffect(.bounce, value: durationMinutes)
            Text(task == nil ? L10n.Schedule.newQuest : L10n.Schedule.tuneQuest)
                .font(AppFonts.title2Black)
            Text(selectedDay.formatted(.dateTime.weekday(.wide).month().day()))
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func labeledField<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textSecondary)
            content()
        }
    }

    private var selectedZoneName: String {
        guard let zoneID else { return L10n.Schedule.standalone }
        return zones.first(where: { $0.id == zoneID })?.name ?? L10n.Schedule.chooseZone
    }

    private var selectedZoneColor: Color {
        guard let zoneID, let zone = zones.first(where: { $0.id == zoneID }) else {
            return AppColors.runtimeFallback
        }
        return zone.color
    }
}
