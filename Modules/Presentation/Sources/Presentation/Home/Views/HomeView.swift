import Common
import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel
    @State private var rewardFlightSessionID: UUID?
    @State private var animatedPoints: Int?
    @State private var pointsPulse = 0
    @State private var pointsAnimationTask: Task<Void, Never>?
    private let onBecameActive: (HomeViewModel) -> Void
    
    init(
        viewModel: HomeViewModel,
        onBecameActive: @escaping (HomeViewModel) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBecameActive = onBecameActive
    }
    
    var body: some View {
        let state = viewModel.state
        
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()
            
            if state.failure != nil, state.success == nil {
                failureView
            } else if let success = state.success {
                content(state, success: success)
            }
            
            if state.isLoading {
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
        .toolbarBackground(.hidden, for: .navigationBar)
        .task { viewModel.send(.appeared) }
        .onAppear {
            onBecameActive(viewModel)
            viewModel.send(.appeared)
        }
        .sheet(item: selectedSessionBinding) { detail in
            HomeSessionActionSheet(
                item: detail.item,
                task: detail.task,
                window: state.success?.timelineWindow,
                isMutating: state.isMutating,
                onReschedule: {
                    viewModel.send(.rescheduleSession(sessionID: detail.id, start: $0))
                },
                onSetLock: {
                    viewModel.send(.setSessionLock(sessionID: detail.id, isLocked: $0))
                },
                onDelete: { viewModel.send(.deleteSession(detail.id)) },
                onDismiss: { viewModel.send(.dismissSession) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert(L10n.Home.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) { viewModel.send(.dismissError) }
        } message: {
            Text(state.failure?.message ?? L10n.Common.pleaseTryAgain)
        }
        .overlayPreferenceValue(RewardAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if let sessionID = rewardFlightSessionID,
                   let animation = viewModel.state.completionRewardAnimation,
                   animation.sessionID == sessionID,
                   let destinationAnchor = anchors["points-badge"] {
                    let destinationRect = proxy[destinationAnchor]
                    let sourceRect = anchors[
                        "session-points-\(sessionID.uuidString)"
                    ].map { proxy[$0] } ?? CGRect(
                        x: destinationRect.midX - 1,
                        y: destinationRect.maxY + 80,
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
                        onFinished: {
                            pointsAnimationTask?.cancel()
                            pointsAnimationTask = nil
                            animatedPoints = nil
                            rewardFlightSessionID = nil

                            if let reward = viewModel.state.completionReward,
                               let transition = reward.streakTransition {
                                presentStreak(
                                    transition,
                                    isNewRecord: reward.maxStreakBroken
                                )
                            }

                            viewModel.send(.dismissCompletionReward)
                            viewModel.send(.dismissCompletionRewardAnimation)
                        }
                    )
                    .id(animation.id)
                }
            }
            .allowsHitTesting(false)
        }
        .onChange(of: viewModel.state.completionReward) { _, reward in
            guard viewModel.state.completionRewardAnimation == nil,
                  let reward,
                  let transition = reward.streakTransition else {
                return
            }
            presentStreak(transition, isNewRecord: reward.maxStreakBroken)
            viewModel.send(.dismissCompletionReward)
        }
        .onChange(of: viewModel.state.completionRewardAnimation) { _, animation in
            guard let animation else { return }
            pointsAnimationTask?.cancel()
            pointsAnimationTask = nil
            animatedPoints = animation.oldPoints
            rewardFlightSessionID = animation.sessionID
        }
    }


    private func content(_ state: HomeState, success: HomeSuccessState) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                HomeHeaderView(
                    displayName: success.displayName,
                    selectedDay: state.selectedDay,
                    streakCount: success.streakCount,
                    rewardPoints: animatedPoints ?? success.rewardPoints,
                    onOpenCalendar: {
                        coordinator.mainCoordinator.push(.calendar)
                    },
                    onSelectToday: {
                        viewModel.send(.selectDay(.now))
                    },
                    pointsPulse: pointsPulse
                )

                HomeWeekStripView(
                    selectedDay: state.selectedDay,
                    onSelect: { viewModel.send(.selectDay($0)) }
                )

                HomePlanSummaryView(
                    taskCount: success.taskCount,
                    scheduledMinutes: success.scheduledMinutes,
                    completedCount: success.completedSessionCount,
                    totalCount: success.totalSessionCount,
                    taskAllocations: success.taskAllocations
                )

                HomeDayTimelineView(
                    window: success.timelineWindow,
                    wakeupTime: success.timelineWakeupTime,
                    bedtime: success.timelineBedtime,
                    zones: success.timelineZones,
                    items: success.timelineItems,
                    onMove: { sessionID, points in
                        viewModel.send(
                            .moveSession(
                                sessionID: sessionID,
                                verticalPoints: points,
                                hourHeight: HomeDayTimelineView.hourHeight
                            )
                        )
                    },
                    onSetCompletion: { sessionID, isCompleted in
                        viewModel.send(
                            .setSessionCompletion(
                                sessionID: sessionID,
                                isCompleted: isCompleted
                            )
                        )
                    },
                    onTap: { viewModel.send(.presentSession($0))}
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable { viewModel.send(.refresh) }
    }

    private var failureView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)
            Text(L10n.Home.loadFailed)
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
            get: {
                viewModel.state.failure != nil
                    && viewModel.state.success != nil
            },
            set: { if !$0 { viewModel.send(.dismissError) } }
        )
    }

    private var selectedSessionBinding: Binding<HomeSessionDetail?> {
        Binding(
            get: { viewModel.state.selectedSession },
            set: { if $0 == nil { viewModel.send(.dismissSession) } }
        )
    }
    private func animatePoints(
        from oldValue: Int,
        to newValue: Int
    ) {
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

    private func presentStreak(
        _ transition: HomeStreakTransition,
        isNewRecord: Bool
    ) {
        coordinator.mainCoordinator.presentStreakCelebration(
            previousStreak: transition.oldValue,
            streak: transition.newValue,
            isNewRecord: isNewRecord
        )
    }
    
}
