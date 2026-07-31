import Common
import Domain
import SwiftUI

struct AITaskResultSheet: View {
    let items: [AITaskSheetItem]
    let onAdd: (AITaskSheetItem, Int) -> Void
    let onDismiss: () -> Void

    @State private var editedDurationMinutes: [UUID: Int]
    @State private var sessionDurations: [UUID: [Int: Int]]
    @State private var addedTaskIDs: Set<UUID> = []

    init(
        items: [AITaskSheetItem],
        onAdd: @escaping (AITaskSheetItem, Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.items = items
        self.onAdd = onAdd
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
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

                // Render a card for each AI task
                ForEach(items) { item in
                    taskCard(for: item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 34)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private func taskCard(for item: AITaskSheetItem) -> some View {
        let itemDuration = editedDurationMinutes[item.id] ?? max(15, item.task.duration.minutes)

        return AppCard {
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
                                if itemDuration > 15 {
                                    editedDurationMinutes[item.id] = itemDuration - 15
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(itemDuration > 15 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                            }
                            .disabled(itemDuration <= 15)

                            Text(L10n.Home.minutesShort(itemDuration))
                                .font(AppFonts.headlineBlack)
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(minWidth: 65)

                            Button {
                                if itemDuration < 480 {
                                    editedDurationMinutes[item.id] = itemDuration + 15
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(itemDuration < 480 ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.4))
                            }
                            .disabled(itemDuration >= 480)
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
                            Text(Self.timeFormatter.string(from: item.startTime.addingTimeInterval(Double(itemDuration) * 60)))
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                } else {
                    if item.task.category != nil {
                        Divider()
                    }
                    ForEach(Array(item.sessions.enumerated()), id: \.offset) { index, session in
                        sessionView(item: item, index: index, session: session)
                        if index != item.sessions.count - 1 {
                            Divider()
                        }
                    }
                }

                if let reason = item.reason, !reason.isEmpty {
                    Divider()
                    Text(reason)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                let isAdded = addedTaskIDs.contains(item.id)

                HStack(spacing: 12) {
                    AppButton(
                        title: "Goal",
                        icon: "target",
                        color: AppColors.accentPurple,
                        size: .regular,
                        onTap: {}
                    )

                    AppButton(
                        title: isAdded ? L10n.Home.btnAddManualTask : L10n.Home.btnAddManualTask,
                        icon: isAdded ? "checkmark.circle.fill" : "plus.circle.fill",
                        color: isAdded ? AppColors.textSecondary.opacity(0.4) : AppColors.accentBlue,
                        size: .regular,
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
    }

    private func sessionView(item: AITaskSheetItem, index: Int, session: AiProposedSession) -> some View {
        let duration = sessionDurations[item.id]?[index] ?? session.timeRange.durationMinutes
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
                            var taskDurations = sessionDurations[item.id] ?? [:]
                            taskDurations[index] = duration - incrementStep
                            sessionDurations[item.id] = taskDurations
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
                            var taskDurations = sessionDurations[item.id] ?? [:]
                            taskDurations[index] = duration + incrementStep
                            sessionDurations[item.id] = taskDurations
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
    AITaskResultSheet(items: [.mock], onAdd: { _, _ in }, onDismiss: {})
}
