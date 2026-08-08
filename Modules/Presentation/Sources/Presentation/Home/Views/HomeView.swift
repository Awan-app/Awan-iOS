import Common
import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel
    @State private var rewardFlightSessionID: UUID?
    @State private var animatedPoints: Int?
    @State private var pointsPulse = 0
    
    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
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
                   let sourceAnchor = anchors[
                    "session-points-\(sessionID.uuidString)"
                   ],
                   let destinationAnchor = anchors["points-badge"] {
                    
                    RewardFlightOverlay(
                        sourceRect: proxy[sourceAnchor],
                        destinationRect: proxy[destinationAnchor],
                        points: animation.newPoints - animation.oldPoints,
                        onArrived: {
                            animatePoints(
                                from: animation.oldPoints,
                                to: animation.newPoints
                            )
                        },
                        onFinished: {
                            rewardFlightSessionID = nil
                            viewModel.send(.dismissCompletionRewardAnimation)
                        }
                    )
                    .id(animation.id)
                }
            }
            .allowsHitTesting(false)
        }
    }


    private func content(_ state: HomeState, success: HomeSuccessState) -> some View {
        ScrollView {
            LazyVStack(spacing: 18) {
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
                    pointsPulse: pointsPulse,
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
                    onTap: { viewModel.send(.presentSession($0))},
                    onPointsRewardHidden: { sessionID in
                        guard let animation = viewModel.state.completionRewardAnimation,
                              animation.sessionID == sessionID else {
                            return
                        }

                        animatedPoints = animation.oldPoints
                        rewardFlightSessionID = sessionID
                    }
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
        Task { @MainActor in
            let difference = newValue - oldValue

            guard difference > 0 else {
                animatedPoints = newValue
                return
            }

            let steps = min(difference, 20)

            for step in 1...steps {
                let progress = Double(step) / Double(steps)

                animatedPoints =
                    oldValue + Int(
                        Double(difference) * progress
                    )

                try? await Task.sleep(
                    for: .milliseconds(15)
                )
            }

            animatedPoints = newValue
            pointsPulse += 1
        }
    }
    
}

