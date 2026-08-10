import Common
import SwiftUI

struct GoalScheduleSessionEditorSheet: View {
    let context: GoalScheduleEditorContext
    let onSave: (Date, Date) -> Void
    let onDismiss: () -> Void

    @Environment(\.calendar) private var calendar
    @State private var day: Date
    @State private var start: Date
    @State private var durationMinutes: Int

    init(
        context: GoalScheduleEditorContext,
        onSave: @escaping (Date, Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.context = context
        self.onSave = onSave
        self.onDismiss = onDismiss
        _day = State(initialValue: context.start)
        _start = State(initialValue: context.start)
        _durationMinutes = State(initialValue: context.durationMinutes)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    scheduleFields

                    AppButton(
                        title: L10n.Common.save,
                        icon: "checkmark.circle.fill",
                        color: AppColors.accentBlue,
                        onTap: save
                    )
                }
                .padding(20)
            }
            .background(AppColors.screenBackground.ignoresSafeArea())
            .navigationTitle(L10n.Home.editSessionSchedule)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel, action: onDismiss)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var scheduleFields: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 18),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlueDepth.opacity(0.45),
            depthOffset: 5
        ) {
            VStack(spacing: 14) {
                AppDatePickerField(
                    selection: $day,
                    title: L10n.Home.sessionDay,
                    in: Date.distantPast...Date.distantFuture
                )

                Divider()

                HStack {
                    Label(L10n.Home.sessionStart, systemImage: "clock.fill")
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    DatePicker(
                        L10n.Home.sessionStart,
                        selection: $start,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .tint(AppColors.accentBlue)
                }

                if context.allowsDurationEditing {
                    Divider()
                    HStack(spacing: 12) {
                        Text(L10n.GoalCreation.sessionDuration)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer(minLength: 8)
                        DurationStepperControl(durationMinutes: $durationMinutes)
                    }
                }
            }
        }
    }

    private func save() {
        let dayParts = calendar.dateComponents([.year, .month, .day], from: day)
        let timeParts = calendar.dateComponents([.hour, .minute], from: start)
        guard let normalizedStart = calendar.date(
            from: DateComponents(
                year: dayParts.year,
                month: dayParts.month,
                day: dayParts.day,
                hour: timeParts.hour,
                minute: timeParts.minute
            )
        ), let end = calendar.date(
            byAdding: .minute,
            value: durationMinutes,
            to: normalizedStart
        ) else { return }
        onSave(normalizedStart, end)
    }
}
