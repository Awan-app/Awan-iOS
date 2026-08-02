//
//  ImageToTasksResultSheet.swift
//  Presentation

import Common
import Domain
import SwiftUI

struct ImageToTasksResultSheet: View {
    let response: TaskProposalResponse
    let categories: [TaskCategory]
    let zones: [Zone]
    let onConfirm: ([ProposedTask]) -> Void
    let onDismiss: () -> Void

    @State private var tasks: [ProposedTask]
    @State private var selectedTaskIDs: Set<UUID>

    init(
        response: TaskProposalResponse,
        categories: [TaskCategory],
        zones: [Zone],
        onConfirm: @escaping ([ProposedTask]) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.response = response
        self.categories = categories
        self.zones = zones
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        _tasks = State(initialValue: response.tasks)
        _selectedTaskIDs = State(initialValue: Set(response.tasks.map { $0.id }))
    }

    private var selectedTasks: [ProposedTask] {
        tasks.filter { selectedTaskIDs.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Text(L10n.Home.imageToTasksTitle)
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
                VStack {
                    AppButton(
                        title: L10n.Home.confirmAcceptCount(selectedTasks.count),
                        icon: "checkmark.circle.fill",
                        color: selectedTasks.isEmpty ? AppColors.buttonDisabled : AppColors.accentBlue,
                        size: .large,
                        onTap: {
                            guard !selectedTasks.isEmpty else { return }
                            onConfirm(selectedTasks)
                        }
                    )
                    .disabled(selectedTasks.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.screenBackground)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }
}
