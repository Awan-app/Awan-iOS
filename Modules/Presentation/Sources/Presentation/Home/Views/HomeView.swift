import Common
import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

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
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear
                .frame(height: 10)
                .frame(maxWidth: .infinity)
                .background {
                    LinearGradient(
                        colors: [
                            AppColors.skyGradientTop,
                            AppColors.screenBackground,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                }
                .allowsHitTesting(false)
        }
        .navigationBarHidden(true)
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
    }

    private func content(_ state: HomeState, success: HomeSuccessState) -> some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                HomeHeaderView(
                    displayName: success.displayName,
                    selectedDay: state.selectedDay,
                    streakCount: success.streakCount,
                    rewardPoints: success.rewardPoints
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
                    taskAllocations: success.taskAllocations,
                    onAddTask: {},
                    onAddGoal: {}
                )

                HomeDayTimelineView(
                    window: success.timelineWindow,
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
                    onTap: { viewModel.send(.presentSession($0)) }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
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
}
