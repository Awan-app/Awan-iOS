import Common
import Domain
import SwiftUI

struct AITaskResultSheet: View {
    let items: [AITaskSheetItem]
    let onAdd: (AITaskSheetItem, Int) -> Void
    let onAddToInbox: ([AITaskSheetItem]) -> Void
    let onDismiss: () -> Void

    @State private var editedDurationMinutes: [UUID: Int]
    @State private var sessionDurations: [UUID: [Int: Int]]
    @State private var addedTaskIDs: Set<UUID> = []

    init(
        items: [AITaskSheetItem],
        onAdd: @escaping (AITaskSheetItem, Int) -> Void,
        onAddToInbox: @escaping ([AITaskSheetItem]) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.items = items
        self.onAdd = onAdd
        self.onAddToInbox = onAddToInbox
        self.onDismiss = onDismiss

        var initialEditedDurations: [UUID: Int] = [:]
        var initialSessionDurations: [UUID: [Int: Int]] = [:]

        for item in items {
            initialEditedDurations[item.id] = max(15, item.task.duration.minutes)
            var durations: [Int: Int] = [:]
            for (index, session) in item.sessions.enumerated() {
                durations[index] = session.timeRange.durationMinutes
            }
            initialSessionDurations[item.id] = durations
        }

        _editedDurationMinutes = State(initialValue: initialEditedDurations)
        _sessionDurations = State(initialValue: initialSessionDurations)
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
        VStack(spacing: 0) {
            // Top Navigation Bar
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
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(items) { item in
                        taskCard(for: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private func taskCard(for item: AITaskSheetItem) -> some View {
        let itemDuration = editedDurationMinutes[item.id] ?? max(15, item.task.duration.minutes)
        let isAdded = addedTaskIDs.contains(item.id)

        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                // Task Title & Description header
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.task.title)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        if let description = item.task.description, !description.isEmpty {
                            Text(description)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Spacer()
                }

                Divider()

                // Category chip
                if let category = item.task.category {
                    HStack(spacing: 8) {
                        Label(category.name, systemImage: "tag.fill")
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.accentBlue.opacity(0.12), in: Capsule())

                        Spacer()

                        Label("\(item.task.estimatedPoints) pts", systemImage: "star.fill")
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.reward)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                }

                // Duration stepper
                HStack {
                    Text(L10n.Home.duration)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            if itemDuration > 15 {
                                editedDurationMinutes[item.id] = itemDuration - 15
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    itemDuration > 15
                                        ? AppColors.accentBlue
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                        }
                        .disabled(itemDuration <= 15)

                        Text(L10n.Home.minutesShort(itemDuration))
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(minWidth: 55)

                        Button {
                            if itemDuration < 480 {
                                editedDurationMinutes[item.id] = itemDuration + 15
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    itemDuration < 480
                                        ? AppColors.accentBlue
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                        }
                        .disabled(itemDuration >= 480)
                    }
                }

                // Sessions
                if !item.sessions.isEmpty {
                    aiSessionsRow(for: item)
                } else {
                    // Start / End time row when no sessions
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

                        Image(systemName: "arrow.forward")
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(L10n.Home.endTime)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textSecondary)
                            Text(Self.timeFormatter.string(from: item.startTime.addingTimeInterval(Double(itemDuration) * 60)))
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }

                // Reason chip
                if let reason = item.reason, !reason.isEmpty {
                    ProposedTaskReasonChip(reason: reason)
                }

                Divider()

                // Action buttons
                HStack(spacing: 12) {
                    AppButton(
                        title: L10n.Home.addToInbox,
                        icon: "tray.fill",
                        color: AppColors.accentPurple,
                        foregroundColor: AppColors.otpWhite,
                        borderColor: AppColors.divider,
                        size: .large,
                        useGradient: false,
                        onTap: {
                            
                        }
                    )
                    .disabled(isAdded)

                    AppButton(
                        title: isAdded ? L10n.Home.btnAddManualTask : L10n.Home.btnAddManualTask,
                        icon: isAdded ? "checkmark.circle.fill" : "plus.circle.fill",
                        color: isAdded ? AppColors.buttonDisabled : AppColors.accentBlue,
                        size: .large,
                        onTap: {
                            guard !isAdded else { return }
                            let finalDuration: Int
                            if item.sessions.isEmpty {
                                finalDuration = editedDurationMinutes[item.id] ?? itemDuration
                            } else {
                                finalDuration = item.sessions.enumerated().reduce(0) { total, pair in
                                    total + (sessionDurations[item.id]?[pair.offset] ?? pair.element.timeRange.durationMinutes)
                                }
                            }
                            addedTaskIDs.insert(item.id)
                            onAdd(item, finalDuration)
                        }
                    )
                    .disabled(isAdded)
                }
            }
        }
        .opacity(isAdded ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAdded)
    }

    @ViewBuilder
    private func aiSessionsRow(for item: AITaskSheetItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(AppFonts.caption2Bold)
                Text(L10n.Home.proposedTaskAiSession)
                    .font(AppFonts.caption2Bold)
            }
            .foregroundStyle(AppColors.accentBlue)

            HStack(spacing: 6) {
                ForEach(Array(item.sessions.enumerated()), id: \.offset) { index, session in
                    let duration = sessionDurations[item.id]?[index] ?? session.timeRange.durationMinutes
                    let computedEnd = session.timeRange.start.addingTimeInterval(Double(duration) * 60)
                    Text("\(Self.timeFormatter.string(from: session.timeRange.start)) – \(Self.timeFormatter.string(from: computedEnd))")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppColors.accentBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AITaskResultSheet(items: [.mock], onAdd: { _, _ in }, onAddToInbox: { _ in }, onDismiss: {})
}
