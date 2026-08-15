//
//  InboxView.swift
//  Presentation
//

import Common
import SwiftUI

public struct InboxView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: InboxViewModel
    @State private var goalsViewModel: GoalsViewModel
    @State private var isFilterExpanded = false
    @State private var taskToDelete: InboxTaskItem?
    @State private var isDeleteAlertPresented = false
    @State private var rewardFlightTaskID: UUID?
    @State private var animatedPoints: Int?
    @State private var pointsPulse = 0
    @State private var pointsAnimationTask: Task<Void, Never>?

    public init(
        viewModel: InboxViewModel,
        goalsViewModel: GoalsViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        _goalsViewModel = State(initialValue: goalsViewModel)
    }

    public var body: some View {
        let state = viewModel.state

        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            if let failure = state.failureMessage, state.allTasks.isEmpty {
                failureView(message: failure)
            } else {
                content(state)
            }

            if state.isLoading && state.allTasks.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .padding(22)
                    .background(
                        AppMaterials.loadingOverlay,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.send(.appeared)
        }
        .alert(L10n.Inbox.errorTitle, isPresented: errorBinding) {
            Button("OK") {
                viewModel.send(.dismissError)
            }
        } message: {
            Text(state.failureMessage ?? L10n.Inbox.loadFailed)
        }
        .alert(L10n.Inbox.deleteTaskConfirmTitle, isPresented: $isDeleteAlertPresented, presenting: taskToDelete) { task in
            Button(role: .destructive) {
                viewModel.send(.deleteTask(task.id))
                taskToDelete = nil
            } label: {
                Text(L10n.Inbox.deleteTask)
            }
            Button(role: .cancel) {
                taskToDelete = nil
            } label: {
                Text(L10n.Common.cancel)
            }
        } message: { _ in
            Text(L10n.Inbox.deleteTaskConfirmMessage)
        }
        .overlayPreferenceValue(RewardAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if let taskID = rewardFlightTaskID,
                   let animation = viewModel.state.completionRewardAnimation,
                   animation.taskID == taskID {
                    let destinationRect = anchors["inbox-points-badge"]
                        .map { proxy[$0] } ?? CGRect(
                            x: proxy.size.width - 50,
                            y: 50,
                            width: 2,
                            height: 2
                        )
                    let sourceRect = anchors[
                        "task-points-\(taskID.uuidString)"
                    ].map { proxy[$0] } ?? CGRect(
                        x: proxy.size.width / 2 - 1,
                        y: proxy.size.height / 2 - 1,
                        width: 2,
                        height: 2
                    )

                    RewardFlightOverlay(
                        sourceRect: sourceRect,
                        destinationRect: destinationRect,
                        points: animation.newPoints - animation.oldPoints,
                        onArrived: {
                            animatePoints(
                                from: animation.oldPoints,
                                to: animation.newPoints
                            )
                        },
                        onFinished: finishRewardFlight
                    )
                    .id(animation.id)
                }
            }
            .allowsHitTesting(false)
        }
        .onChange(of: viewModel.state.completionReward) { _, reward in
            guard viewModel.state.completionRewardAnimation == nil,
                  let transition = reward?.streakTransition else {
                return
            }
            presentStreak(transition)
            viewModel.send(.dismissCompletionReward)
        }
        .onChange(of: viewModel.state.completionRewardAnimation) { _, animation in
            guard let animation else { return }
            pointsAnimationTask?.cancel()
            pointsAnimationTask = nil
            animatedPoints = animation.oldPoints
            rewardFlightTaskID = animation.taskID
        }
        .onDisappear {
            pointsAnimationTask?.cancel()
            pointsAnimationTask = nil
        }
    }

    private func content(_ state: InboxState) -> some View {
        List {
            Group {
                InboxHeaderView(
                    selectedTopTab: Binding(
                        get: { state.selectedTopTab },
                        set: { viewModel.send(.selectTopTab($0)) }
                    ),
                    rewardPoints: animatedPoints ?? state.userPoints,
                    pointsPulse: pointsPulse
                )

                if state.selectedTopTab == .inbox {

                    InboxSearchFilterBar(
                        searchQuery: Binding(
                            get: { state.searchQuery },
                            set: { viewModel.send(.searchQueryChanged($0)) }
                        ),
                        isFilterExpanded: $isFilterExpanded,
                        hasActiveFilters: state.selectedTaskFilter != .all
                            || state.selectedSessionFilter != .any,
                        showsFilterButton: true
                    )

                    if isFilterExpanded {
                        InboxFilterChipsRow(
                            selectedTaskFilter: Binding(
                                get: { state.selectedTaskFilter },
                                set: { viewModel.send(.taskFilterChanged($0)) }
                            ),
                            selectedSessionFilter: Binding(
                                get: { state.selectedSessionFilter },
                                set: { viewModel.send(.sessionFilterChanged($0)) }
                            )
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    sectionTitleRow(count: state.filteredTasks.count)


                    if state.filteredTasks.isEmpty {
                        InboxEmptyView()
                            .padding(.top, 20)
                    } else {
                        ForEach(state.filteredTasks) { taskItem in
                            InboxTaskCard(
                                taskItem: taskItem,
                                isExpanded: state.expandedTaskIDs.contains(taskItem.id),
                                isCompletionDisabled: state.mutatingTaskIDs.contains(taskItem.id),
                                onToggleExpand: {
                                    viewModel.send(.toggleTaskExpansion(taskItem.id))
                                },
                                onCompleteTask: {
                                    viewModel.send(.completeTask(taskItem.id))
                                },
                                onDeleteTask: {
                                    viewModel.send(.deleteTask(taskItem.id))
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    taskToDelete = taskItem
                                    isDeleteAlertPresented = true
                                } label: {
                                    Label(L10n.Inbox.deleteTask, systemImage: "trash.fill")
                                }
                                .tint(AppColors.destructive)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                        }
                    }
                } else {
                    GoalsContentSection(viewModel: goalsViewModel)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 18, trailing: 16))

            // Bottom clearance for CustomTabBar inside scroll content
            Color.clear
                .frame(height: 100)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 12)
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            viewModel.send(.refresh)
        }
    }

    private func sectionTitleRow(count: Int) -> some View {
        HStack(spacing: 8) {
            Text(L10n.Inbox.sectionTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text("\(count)")
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(AppColors.accentBlue.opacity(0.12))
                )

            Spacer()
        }
        .padding(.top, 4)
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)

            Text(L10n.Inbox.loadFailed)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            AppButton(
                title: L10n.Home.retry,
                icon: "arrow.clockwise",
                color: AppColors.accentBlue,
                onTap: { viewModel.send(.refresh) }
            )
            .frame(maxWidth: 220)
        }
        .padding(24)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.failureMessage != nil && !viewModel.state.allTasks.isEmpty },
            set: { if !$0 { viewModel.send(.dismissError) } }
        )
    }

    private func animatePoints(from oldValue: Int, to newValue: Int) {
        pointsAnimationTask?.cancel()

        pointsAnimationTask = Task { @MainActor in
            defer {
                if !Task.isCancelled {
                    animatedPoints = nil
                }
            }

            let difference = newValue - oldValue
            guard difference > 0 else {
                if !Task.isCancelled {
                    pointsPulse += 1
                }
                return
            }

            let steps = min(difference, 20)
            for step in 1...steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                animatedPoints = oldValue + Int(Double(difference) * progress)

                do {
                    try await Task.sleep(for: .milliseconds(15))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            pointsPulse += 1
        }
    }

    private func finishRewardFlight() {
        pointsAnimationTask?.cancel()
        pointsAnimationTask = nil
        animatedPoints = nil
        rewardFlightTaskID = nil

        if let transition = viewModel.state.completionReward?.streakTransition {
            presentStreak(transition)
        }

        viewModel.send(.dismissCompletionReward)
        viewModel.send(.dismissCompletionRewardAnimation)
    }

    private func presentStreak(_ transition: InboxStreakTransition) {
        coordinator.mainCoordinator.presentStreakCelebration(
            previousStreak: transition.oldValue,
            streak: transition.newValue,
            isNewRecord: transition.isNewRecord
        )
    }
}
