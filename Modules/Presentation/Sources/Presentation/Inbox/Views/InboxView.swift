//
//  InboxView.swift
//  Presentation
//

import Common
import SwiftUI

public struct InboxView: View {
    @State private var viewModel: InboxViewModel
    @State private var isFilterExpanded = false

    public init(viewModel: InboxViewModel) {
        _viewModel = State(initialValue: viewModel)
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
    }

    private func content(_ state: InboxState) -> some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                InboxHeaderView(
                    selectedTopTab: Binding(
                        get: { state.selectedTopTab },
                        set: { viewModel.send(.selectTopTab($0)) }
                    )
                )

                if state.selectedTopTab == .inbox {

                    InboxSearchFilterBar(
                        searchQuery: Binding(
                            get: { state.searchQuery },
                            set: { viewModel.send(.searchQueryChanged($0)) }
                        ),
                        isFilterExpanded: $isFilterExpanded,
                        hasActiveFilters: state.selectedTaskFilter != .all
                            || state.selectedSessionFilter != .any
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
                        LazyVStack(spacing: 10) {
                            ForEach(state.filteredTasks) { taskItem in
                                InboxTaskCard(
                                    taskItem: taskItem,
                                    isExpanded: state.expandedTaskIDs.contains(taskItem.id),
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
                            }
                        }
                    }
                } else {
                    if let goalsViewModel = viewModel.goalsViewModel {
                        GoalsContentSection(viewModel: goalsViewModel)
                    } else {
                        VStack(spacing: 16) {
                            AwanMascotView(state: .goal)
                                .frame(width: 160, height: 120)

                            Text(L10n.Inbox.tabGoals)
                                .font(AppFonts.title2Black)
                                .foregroundStyle(AppColors.textPrimary)

                            Text("Goal management will be available here.")
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .padding(.top, 40)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
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
}
