import Common
import Domain
import SwiftUI

struct TaskSessionScheduleEditorSheet: View {
    let durationIsEditable: Bool
    let navigationTitle: String
    let onSave: (Date, Date) -> Void
    let onDismiss: () -> Void
    @Environment(\.calendar) private var calendar
    @State private var day: Date
    @State private var start: Date
    @State private var durationMinutes: Int

    init(
        session: Session,
        onSave: @escaping (Date, Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        durationIsEditable = false
        navigationTitle = L10n.Home.editSessionSchedule
        self.onSave = onSave
        self.onDismiss = onDismiss
        _day = State(initialValue: session.timeRange.start)
        _start = State(initialValue: session.timeRange.start)
        _durationMinutes = State(initialValue: session.timeRange.durationMinutes)
    }

    init(
        defaultDurationMinutes: Int,
        onSave: @escaping (Date, Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        durationIsEditable = true
        navigationTitle = L10n.GoalCreation.addSession
        self.onSave = onSave
        self.onDismiss = onDismiss
        let now = Date()
        _day = State(initialValue: now)
        _start = State(initialValue: now)
        _durationMinutes = State(initialValue: defaultDurationMinutes)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
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

                            if durationIsEditable {
                                Divider()

                                HStack(spacing: 12) {
                                    Text(L10n.GoalCreation.sessionDuration)
                                        .font(AppFonts.subheadlineHeavy)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Spacer(minLength: 8)
                                    DurationStepperControl(
                                        durationMinutes: $durationMinutes
                                    )
                                }
                            }
                        }
                    }

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
            .navigationTitle(navigationTitle)
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

    private func save() {
        let dayParts = calendar.dateComponents([.year, .month, .day], from: day)
        let timeParts = calendar.dateComponents([.hour, .minute], from: start)
        guard let normalizedStart = calendar.date(from: DateComponents(
            year: dayParts.year,
            month: dayParts.month,
            day: dayParts.day,
            hour: timeParts.hour,
            minute: timeParts.minute
        )), let normalizedEnd = calendar.date(
            byAdding: .minute,
            value: durationMinutes,
            to: normalizedStart
        ) else { return }
        onSave(normalizedStart, normalizedEnd)
    }
}
