import Common
import Domain
import SwiftUI

enum ProposedSessionSource {
    case fixed
    case ai
}

struct ProposedSessionEditorContext: Identifiable {
    let id = UUID()
    let taskID: UUID
    let source: ProposedSessionSource
    let sessionID: UUID?
    let zoneID: UUID?
    let status: String
    let start: Date
    let end: Date

    init(
        taskID: UUID,
        source: ProposedSessionSource,
        session: ProposedSession
    ) {
        self.taskID = taskID
        self.source = source
        sessionID = session.id
        zoneID = session.zoneId
        status = session.status
        start = session.start
        end = session.end
    }

    init(
        taskID: UUID,
        source: ProposedSessionSource,
        start: Date,
        end: Date
    ) {
        self.taskID = taskID
        self.source = source
        sessionID = nil
        zoneID = nil
        status = "SCHEDULED"
        self.start = start
        self.end = end
    }
}

struct ProposedSessionEditorSheet: View {
    let context: ProposedSessionEditorContext
    let onSave: (ProposedSession) -> Void
    let onDismiss: () -> Void

    @Environment(\.calendar) private var calendar
    @State private var sessionDay: Date
    @State private var start: Date
    @State private var end: Date

    init(
        context: ProposedSessionEditorContext,
        onSave: @escaping (ProposedSession) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.context = context
        self.onSave = onSave
        self.onDismiss = onDismiss
        _sessionDay = State(initialValue: context.start)
        _start = State(initialValue: context.start)
        _end = State(initialValue: context.end)
    }

    private var normalizedStart: Date? {
        date(on: sessionDay, withTimeFrom: start)
    }

    private var normalizedEnd: Date? {
        date(on: sessionDay, withTimeFrom: end)
    }

    private var isValid: Bool {
        guard let normalizedStart, let normalizedEnd else { return false }
        return normalizedEnd > normalizedStart
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    sessionDaySection
                    sessionTimesSection

                    if !isValid {
                        Label(
                            L10n.Home.invalidSessionTimeRange,
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AppButton(
                        title: L10n.Common.save,
                        icon: "checkmark.circle.fill",
                        color: isValid
                            ? AppColors.accentBlue
                            : AppColors.buttonDisabled,
                        onTap: save
                    )
                    .disabled(!isValid)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
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

    private var sessionDaySection: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 18),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlueDepth.opacity(0.45),
            depthOffset: 5
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Home.sessionDay)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)

                AppDatePickerField(
                    selection: $sessionDay,
                    title: L10n.Home.sessionDay,
                    in: Date.distantPast...Date.distantFuture
                )
            }
        }
    }

    private var sessionTimesSection: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 18),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlueDepth.opacity(0.45),
            depthOffset: 5
        ) {
            VStack(spacing: 0) {
                timeRow(
                    title: L10n.Home.sessionStart,
                    selection: $start
                )

                Divider()
                    .overlay(AppColors.accentBlue.opacity(0.14))
                    .padding(.vertical, 12)

                timeRow(
                    title: L10n.Home.sessionEnd,
                    selection: $end
                )
            }
        }
    }

    private func timeRow(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        HStack(spacing: 12) {
            Label(title, systemImage: "clock.fill")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            DatePicker(
                title,
                selection: selection,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(AppColors.accentBlue)
        }
    }

    private func save() {
        guard isValid,
              let normalizedStart,
              let normalizedEnd else {
            return
        }
        onSave(
            ProposedSession(
                id: context.sessionID ?? UUID(),
                zoneId: context.zoneID,
                start: normalizedStart,
                end: normalizedEnd,
                status: context.status
            )
        )
    }

    private func date(on day: Date, withTimeFrom time: Date) -> Date? {
        let dayComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: day
        )
        let timeComponents = calendar.dateComponents(
            [.hour, .minute, .second],
            from: time
        )
        return calendar.date(
            from: DateComponents(
                year: dayComponents.year,
                month: dayComponents.month,
                day: dayComponents.day,
                hour: timeComponents.hour,
                minute: timeComponents.minute,
                second: timeComponents.second
            )
        )
    }
}
