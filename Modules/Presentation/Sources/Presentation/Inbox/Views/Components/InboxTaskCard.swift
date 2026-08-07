//
//  InboxTaskCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct InboxTaskCard: View {
    let taskItem: InboxTaskItem
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    var onCompleteTask: (() -> Void)? = nil
    var onDeleteTask: (() -> Void)? = nil

    @State private var localExpanded: Bool

    init(
        taskItem: InboxTaskItem,
        isExpanded: Bool,
        onToggleExpand: @escaping () -> Void,
        onCompleteTask: (() -> Void)? = nil,
        onDeleteTask: (() -> Void)? = nil
    ) {
        self.taskItem = taskItem
        self.isExpanded = isExpanded
        self.onToggleExpand = onToggleExpand
        self.onCompleteTask = onCompleteTask
        self.onDeleteTask = onDeleteTask
        _localExpanded = State(initialValue: isExpanded)
    }

    private var isCompleted: Bool {
        taskItem.derivedStatus == .completed
    }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 24),
            surfaceColor: AppColors.surface,
            borderColor: borderColor,
            depthColor: AppColors.outline.opacity(0.10),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    completionButton

                    VStack(alignment: .leading, spacing: 4) {
                        Text(taskItem.title)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                            .strikethrough(isCompleted, color: AppColors.textSecondary)
                            .multilineTextAlignment(.leading)

                        if let desc = taskItem.description, !desc.isEmpty {
                            Text(desc)
                                .font(AppFonts.captionHeavy)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }

                    Spacer()

                    statusBadge
                }

                if !taskItem.sessionItems.isEmpty {
                    Divider()
                        .background(AppColors.divider)

                    VStack(spacing: 8) {
                        Button {
                            withAnimation(.snappy(duration: 0.25)) {
                                localExpanded.toggle()
                            }
                            onToggleExpand()
                        } label: {
                            HStack {
                                Text(taskItem.sessionItems.count == 1 ? L10n.Inbox.oneSession : L10n.Inbox.nSessions(taskItem.sessionItems.count))
                                    .font(AppFonts.subheadlineHeavy)
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()

                                Image(systemName: localExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.textSecondary)
                                    .animation(.snappy(duration: 0.25), value: localExpanded)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if localExpanded {
                            VStack(spacing: 8) {
                                ForEach(taskItem.sessionItems) { session in
                                    InboxSessionRow(session: session)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
        .onChange(of: isExpanded) { _, newValue in
            withAnimation(.snappy(duration: 0.25)) {
                localExpanded = newValue
            }
        }
    }

    private var borderColor: Color {
        switch taskItem.derivedStatus {
        case .active:
            return AppColors.warning.opacity(0.35)
        case .completed:
            return AppColors.accentGreen.opacity(0.35)
        default:
            return AppColors.outline.opacity(0.12)
        }
    }

    @ViewBuilder
    private var completionButton: some View {
        Button {
            onCompleteTask?()
        } label: {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(AppColors.accentGreenDepth)
                        .offset(y: 2)
                    Circle()
                        .fill(AppColors.accentGreen)
                    Circle()
                        .stroke(AppColors.accentGreenDepth, lineWidth: 1.5)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(AppColors.onAccent)
                } else {
                    Circle()
                        .fill(AppColors.surface)
                    Circle()
                        .stroke(circleStrokeColor, lineWidth: 2.5)
                }
            }
            .frame(width: 24, height: 24)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var circleStrokeColor: Color {
        if isCompleted {
            return AppColors.accentGreen
        }
        if taskItem.sessionItems.contains(where: { $0.displayStatus == .activeNow }) {
            return AppColors.warning
        }
        return AppColors.accentBlue
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch taskItem.derivedStatus {
        case .active:
            Text(L10n.Inbox.filterActive)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.warning)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.warning.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppColors.warning.opacity(0.5), lineWidth: 1.5)
                )
        case .completed, .drafted, .cancelled:
            EmptyView()
        }
    }
}

#Preview("Active Card") {
    InboxTaskCard(
        taskItem: .init(
            id: UUID(),
            title: "Prepare presentation",
            description: "Create slides and rehearse",
            derivedStatus: .active,
            sessionsSummary: "1 completed • 1 scheduled",
            sessionItems: [
                .init(id: UUID(), timeRangeText: "Today, 10:00–11:00 AM", displayStatus: .activeNow, underlyingStatus: .planned),
                .init(id: UUID(), timeRangeText: "Yesterday, 3:00–4:00 PM", displayStatus: .missed, underlyingStatus: .planned)
            ],
            rawTask: AwanTask(id: UUID(), duration: try! TaskDuration(minutes: 30), isSplittable: false)
        ),
        isExpanded: true,
        onToggleExpand: {}
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Completed Card") {
    InboxTaskCard(
        taskItem: .init(
            id: UUID(),
            title: "Set up database schema",
            description: nil,
            derivedStatus: .completed,
            sessionsSummary: "2 completed",
            sessionItems: [],
            rawTask: AwanTask(id: UUID(), duration: try! TaskDuration(minutes: 60), isSplittable: false)
        ),
        isExpanded: false,
        onToggleExpand: {}
    )
    .padding()
    .background(AppColors.screenBackground)
}
