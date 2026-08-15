import Common
import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel
    @State private var rewardFlightSessionID: UUID?
    @State private var animatedPoints: Int?
    @State private var pointsPulse = 0
    @State private var pointsAnimationTask: Task<Void, Never>?
    @State private var pinnedHeaderHeight: CGFloat = 0
    @State private var planSummaryHeight: CGFloat = 0
    @State private var homeScrollFrame: CGRect = .zero
    @State private var homeScrollPosition = ScrollPosition()
    @State private var homeScrollStorage = HomeScrollStorage()
    @State private var isHeaderCollapsed = false
    @State private var draggedSessionID: UUID?
    @State private var dragLocationY: CGFloat?
    @State private var dragScrollCompensation: CGFloat = 0
    @State private var dragMinimumScrollOffset: CGFloat = 0
    private let makeSessionDetailsViewModel: (SessionDetailsContext) -> SessionDetailsViewModel
    private let onBecameActive: (HomeViewModel) -> Void
    
    init(
        viewModel: HomeViewModel,
        makeSessionDetailsViewModel: @escaping (
            SessionDetailsContext
        ) -> SessionDetailsViewModel,
        onBecameActive: @escaping (HomeViewModel) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeSessionDetailsViewModel = makeSessionDetailsViewModel
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
            SessionDetailsView(
                viewModel: makeSessionDetailsViewModel(detail.context),
                onDismiss: { viewModel.send(.dismissSession) }
            )
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
        .ignoresSafeArea(edges: .bottom)
    }

    private func content(_ state: HomeState, success: HomeSuccessState) -> some View {
        VStack(spacing: 0) {
            HomeHeaderView(
                displayName: success.displayName,
                streakCount: success.streakCount,
                rewardPoints: animatedPoints ?? success.rewardPoints,
                pointsPulse: pointsPulse,
                isCollapsed: isHeaderCollapsed
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 5)
            .background(AppColors.screenBackground)

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        HomePlanSummaryView(
                            taskCount: success.taskCount,
                            scheduledMinutes: success.scheduledMinutes,
                            completedCount: success.completedSessionCount,
                            totalCount: success.totalSessionCount,
                            taskAllocations: success.taskAllocations
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 12)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            planSummaryHeight = height
                        }

                        HomeDayTimelineView(
                            window: success.timelineWindow,
                            wakeupTime: success.timelineWakeupTime,
                            bedtime: success.timelineBedtime,
                            zones: success.timelineZones,
                            items: success.timelineItems,
                            draggedSessionID: draggedSessionID,
                            scrollCompensation: dragScrollCompensation,
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
                            onDragChanged: handleTimelineDrag,
                            onTap: { viewModel.send(.presentSession($0)) }
                        )

                        AppCloudsHorizon(height: 150)
                    } header: {
                        HomePinnedDateWeekHeaderView(
                            selectedDay: state.selectedDay,
                            onSelect: { viewModel.send(.selectDay($0)) },
                            onOpenCalendar: {
                                coordinator.mainCoordinator.push(.calendar)
                            },
                            onSelectToday: {
                                viewModel.send(.selectDay(.now))
                            }
                        )
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            pinnedHeaderHeight = height
                        }
                        .zIndex(1)
                    }
                }
            }
            .scrollPosition($homeScrollPosition)
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { frame in
                homeScrollFrame = frame
            }
            .onScrollGeometryChange(for: HomeScrollMetrics.self) { geometry in
                HomeScrollMetrics(
                    offset: max(0, geometry.contentOffset.y),
                    maximumOffset: max(
                        0,
                        geometry.contentSize.height - geometry.containerSize.height
                    ),
                    viewportHeight: geometry.containerSize.height
                )
            } action: { _, metrics in
                homeScrollStorage.metrics = metrics
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                max(0, geometry.contentOffset.y) > 80
            } action: { _, collapsed in
                isHeaderCollapsed = collapsed
            }
            .task(id: draggedSessionID) {
                guard draggedSessionID != nil else { return }

                while !Task.isCancelled {
                    autoScrollTimelineIfNeeded()
                    try? await Task.sleep(for: .milliseconds(16))
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable { viewModel.send(.refresh) }
//            .onChange(of: coordinator.mainCoordinator.selectedTab) { _, tab in
//                guard tab == .home else { return }
//                homeScrollPosition.scrollTo(edge: .top)
//            }
        }
    }

    private func handleTimelineDrag(sessionID: UUID, locationY: CGFloat?) {
        guard let locationY else {
            if draggedSessionID == sessionID {
                draggedSessionID = nil
                dragLocationY = nil
                dragScrollCompensation = 0
            }
            return
        }

        if draggedSessionID != sessionID {
            draggedSessionID = sessionID
            dragScrollCompensation = 0
            dragMinimumScrollOffset = min(
                homeScrollStorage.metrics.offset,
                planSummaryHeight
            )
        }
        dragLocationY = locationY
    }

    private func autoScrollTimelineIfNeeded() {
        guard draggedSessionID != nil,
              let dragLocationY,
              homeScrollStorage.metrics.viewportHeight > 0 else {
            return
        }

        let threshold: CGFloat = 72
        let maximumStep: CGFloat = 10
        let topEdge = homeScrollFrame.minY + pinnedHeaderHeight
        let bottomEdge = homeScrollFrame.maxY
        let distanceFromTop = dragLocationY - topEdge
        let distanceFromBottom = bottomEdge - dragLocationY
        let delta: CGFloat

        if distanceFromTop < threshold,
           homeScrollStorage.metrics.offset > dragMinimumScrollOffset {
            let factor = 1 - min(max(distanceFromTop / threshold, 0), 1)
            delta = -maximumStep * factor
        } else if distanceFromBottom < threshold,
                  homeScrollStorage.metrics.offset
                    < homeScrollStorage.metrics.maximumOffset {
            let factor = 1 - min(max(distanceFromBottom / threshold, 0), 1)
            delta = maximumStep * factor
        } else {
            return
        }

        let boundedDelta = max(
            delta,
            dragMinimumScrollOffset - homeScrollStorage.metrics.offset
        )
        let targetOffset = min(
            max(
                homeScrollStorage.metrics.offset + boundedDelta,
                dragMinimumScrollOffset
            ),
            homeScrollStorage.metrics.maximumOffset
        )
        let actualDelta = targetOffset - homeScrollStorage.metrics.offset
        guard actualDelta != 0 else { return }

        homeScrollPosition.scrollTo(y: targetOffset)
        homeScrollStorage.metrics.offset = targetOffset
        dragScrollCompensation += actualDelta
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

private struct HomeScrollMetrics: Equatable {
    var offset: CGFloat = 0
    var maximumOffset: CGFloat = 0
    var viewportHeight: CGFloat = 0
}

private final class HomeScrollStorage {
    var metrics = HomeScrollMetrics()
}
