//
//  ImageToTasksResultSheet.swift
//  Presentation

import Common
import Domain
import SwiftUI

struct ImageToTasksResultSheet: View {
    let response: TaskProposal
    let categories: [TaskCategory]
    let zones: [Zone]
    let onConfirm: ([ProposedTask]) -> Void
    let onAddToInbox: ([ProposedTask]) -> Void
    let defaultSessionStart: Date
    let onDismiss: () -> Void

    @State private var tasks: [ProposedTask]
    @State private var selectedTaskIDs: Set<UUID>
    @State private var sessionEditor: ProposedSessionEditorContext?

    init(
        response: TaskProposal,
        categories: [TaskCategory],
        zones: [Zone],
        onConfirm: @escaping ([ProposedTask]) -> Void,
        onAddToInbox: @escaping ([ProposedTask]) -> Void,
        defaultSessionStart: Date,
        onDismiss: @escaping () -> Void
    ) {
        self.response = response
        self.categories = categories
        self.zones = zones
        self.onConfirm = onConfirm
        self.onAddToInbox = onAddToInbox
        self.defaultSessionStart = defaultSessionStart
        self.onDismiss = onDismiss
        _tasks = State(initialValue: response.tasks)
        _selectedTaskIDs = State(initialValue: Set(response.tasks.map { $0.id }))
    }

    private var selectedTasks: [ProposedTask] {
        tasks.filter { selectedTaskIDs.contains($0.id) }
    }

    private var canScheduleSelectedTasks: Bool {
        !selectedTasks.isEmpty && selectedTasks.allSatisfy {
            !$0.draft.sessions.isEmpty || !$0.aiProposedSessions.isEmpty
        }
    }

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
                    // Tasks list or empty state
                    if tasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundStyle(AppColors.textSecondary.opacity(0.5))

                            Text(L10n.Home.imageNoTasks)
                                .font(AppFonts.headlineBlack)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(tasks.indices, id: \.self) { index in
                            let task = tasks[index]
                            ProposedTaskCard(
                                task: task,
                                categories: categories,
                                zones: zones,
                                isSelected: selectedTaskIDs.contains(task.id),
                                onToggleSelect: {
                                    if selectedTaskIDs.contains(task.id) {
                                        selectedTaskIDs.remove(task.id)
                                    } else {
                                        selectedTaskIDs.insert(task.id)
                                    }
                                },
                                onDurationChanged: { newDuration in
                                    tasks[index].draft.task.estimatedDuration = newDuration
                                },
                                onCategoryChanged: { categoryID in
                                    tasks[index].draft.task.categoryId = categoryID
                                },
                                onEditSession: { source, session in
                                    sessionEditor = ProposedSessionEditorContext(
                                        taskID: task.id,
                                        source: source,
                                        session: session
                                    )
                                },
                                onAddSession: {
                                    sessionEditor = ProposedSessionEditorContext(
                                        taskID: task.id,
                                        source: .fixed,
                                        start: defaultSessionStart,
                                        end: defaultSessionStart.addingTimeInterval(
                                            TimeInterval(max(1, task.draft.task.estimatedDuration) * 60)
                                        )
                                    )
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            // Bottom Confirm Button
            if !tasks.isEmpty {
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
                            guard !selectedTasks.isEmpty else { return }
                            onAddToInbox(selectedTasks)
                        }
                    )
                    .disabled(selectedTasks.isEmpty)

                    AppButton(
                        title: L10n.Home.scheduleSelectedCount(selectedTasks.count),
                        icon: "calendar.badge.plus",
                        color: canScheduleSelectedTasks
                            ? AppColors.accentBlue
                            : AppColors.buttonDisabled,
                        size: .large,
                        onTap: {
                            guard canScheduleSelectedTasks else { return }
                            onConfirm(selectedTasks)
                        }
                    )
                    .disabled(!canScheduleSelectedTasks)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.screenBackground)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .sheet(item: $sessionEditor) { context in
            ProposedSessionEditorSheet(
                context: context,
                onSave: { session in
                    save(session, for: context)
                    sessionEditor = nil
                },
                onDismiss: {
                    sessionEditor = nil
                }
            )
        }
    }

    private func save(
        _ session: ProposedSession,
        for context: ProposedSessionEditorContext
    ) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == context.taskID }) else {
            return
        }

        switch context.source {
        case .fixed:
            if let sessionID = context.sessionID,
               let sessionIndex = tasks[taskIndex].draft.sessions.firstIndex(
                   where: { $0.id == sessionID }
               ) {
                tasks[taskIndex].draft.sessions[sessionIndex] = session
            } else {
                tasks[taskIndex].draft.sessions.append(session)
            }
        case .ai:
            guard let sessionID = context.sessionID,
                  let sessionIndex = tasks[taskIndex].aiProposedSessions.firstIndex(
                      where: { $0.id == sessionID }
                  ) else {
                return
            }
            tasks[taskIndex].aiProposedSessions[sessionIndex] = session
        }
    }
}
