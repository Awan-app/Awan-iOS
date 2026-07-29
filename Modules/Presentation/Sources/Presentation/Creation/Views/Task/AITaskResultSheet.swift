import Common
import Domain
import SwiftUI

struct AITaskResultSheet: View {
    let item: AITaskSheetItem
    let onAdd: (Int) -> Void
    let onDismiss: () -> Void

    @State private var editedDurationMinutes: Int
    @State private var sessionDurations: [UUID: Int]

    init(
        item: AITaskSheetItem,
        onAdd: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.item = item
        self.onAdd = onAdd
        self.onDismiss = onDismiss
        _editedDurationMinutes = State(initialValue: max(15, item.task.duration.minutes))
        var durations: [UUID: Int] = [:]
        for session in item.sessions {
            durations[session.id] = session.timeRange.durationMinutes
        }
        _sessionDurations = State(initialValue: durations)
    }

    private var computedEndTime: Date {
        item.startTime.addingTimeInterval(Double(editedDurationMinutes) * 60)
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                // Header bar with title and close button
                HStack {
                    Text(L10n.Home.aiTaskResultTitle)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                // Main Info Card using AppCard
                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        // Task Title & Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.task.title)
                                .font(AppFonts.title2Black)
                                .foregroundStyle(AppColors.textPrimary)

                            if let description = item.task.description, !description.isEmpty {
                                Text(description)
                                    .font(AppFonts.subheadlineSemibold)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }

                        if item.task.category != nil || item.sessions.isEmpty {
                            Divider()
                        }

                        // Category / Zone
                        if let category = item.task.category {
                            HStack {
                                Text(L10n.Home.aiTaskCategory)
                                    .font(AppFonts.caption2Bold)
                                    .foregroundStyle(AppColors.textSecondary)
                                Spacer()
                                Text(category.name)
                                    .font(AppFonts.subheadlineHeavy)
                                    .foregroundStyle(AppColors.accentBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(AppColors.accentBlue.opacity(0.12), in: Capsule())
                            }
                            if item.sessions.isEmpty {
                                Divider()
                            }
                        }

                        if item.sessions.isEmpty {
                            // Empty sessions fallback
                            HStack {
                                Text(L10n.Home.duration)
                                    .font(AppFonts.captionHeavy)
                                    .foregroundStyle(AppColors.textSecondary)

                                Spacer()

                                HStack(spacing: 12) {
                                    Button {
                                        if editedDurationMinutes > 15 {
                                            editedDurationMinutes -= 15
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(editedDurationMinutes > 15 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                                    }
                                    .disabled(editedDurationMinutes <= 15)

                                    Text(L10n.Home.minutesShort(editedDurationMinutes))
                                        .font(AppFonts.headlineBlack)
                                        .foregroundStyle(AppColors.textPrimary)
                                        .frame(minWidth: 65)

                                    Button {
                                        if editedDurationMinutes < 480 {
                                            editedDurationMinutes += 15
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(editedDurationMinutes < 480 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                                    }
                                    .disabled(editedDurationMinutes >= 480)
                                }
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.Home.startTime)
                                        .font(AppFonts.captionHeavy)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Text(Self.timeFormatter.string(from: item.startTime))
                                        .font(AppFonts.subheadlineHeavy)
                                        .foregroundStyle(AppColors.textPrimary)
                                }

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(AppFonts.subheadlineBold)
                                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(L10n.Home.endTime)
                                        .font(AppFonts.captionHeavy)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Text(Self.timeFormatter.string(from: computedEndTime))
                                        .font(AppFonts.subheadlineHeavy)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                            }
                        } else {
                            if item.task.category != nil {
                                Divider()
                            }
                            ForEach(item.sessions) { session in
                                sessionView(for: session)
                                if session.id != item.sessions.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                // 3D Add Button using AppButton
                AppButton(
                    title: L10n.Home.btnAddManualTask,
                    icon: "plus.circle.fill",
                    color: AppColors.accentBlue,
                    size: .regular,
                    onTap: {
                        let finalDuration: Int
                        if item.sessions.isEmpty {
                            finalDuration = editedDurationMinutes
                        } else {
                            finalDuration = item.sessions.reduce(0) { total, session in
                                total + (sessionDurations[session.id] ?? session.timeRange.durationMinutes)
                            }
                        }
                        onAdd(finalDuration)
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 34)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private func sessionView(for session: Session) -> some View {
        let duration = sessionDurations[session.id] ?? session.timeRange.durationMinutes
        let incrementStep = 15
        let computedEnd = session.timeRange.start.addingTimeInterval(Double(duration) * 60)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(Self.dayFormatter.string(from: session.timeRange.start))
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                Text(L10n.Home.duration)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        if duration > incrementStep {
                            sessionDurations[session.id] = duration - incrementStep
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(duration > incrementStep ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                    }
                    .disabled(duration <= incrementStep)

                    Text(L10n.Home.minutesShort(duration))
                        .font(AppFonts.headlineBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(minWidth: 65)

                    Button {
                        if duration < 480 {
                            sessionDurations[session.id] = duration + incrementStep
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(duration < 480 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                    }
                    .disabled(duration >= 480)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Home.startTime)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(Self.timeFormatter.string(from: session.timeRange.start))
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()
                Image(systemName: "arrow.right")
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.Home.endTime)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(Self.timeFormatter.string(from: computedEnd))
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }
}

#Preview {
    AITaskResultSheet(item: .mock, onAdd: { _ in }, onDismiss: {})
}
