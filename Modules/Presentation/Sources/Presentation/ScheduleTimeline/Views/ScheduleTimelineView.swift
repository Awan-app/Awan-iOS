import Common
import Domain
import SwiftUI

struct ScheduleTimelineView: View {
    @State private var viewModel: ScheduleTimelineViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(LanguageManager.self) private var languageManager

    init(viewModel: ScheduleTimelineViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let state = viewModel.state

        ZStack {
            AppColors.screenBackground.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 20) {
                    HStack {
                        QuestHeaderView(
                            selectedDayTitle: state.selectedDayTitle,
                            scheduledMinutes: state.scheduledMinutes,
                            goalProgress: state.activeGoalProgress
                        )
                        
                        Menu {
                            Button("English") { languageManager.currentLanguage = .english }
                            Button("العربية") { languageManager.currentLanguage = .arabic }
                        } label: {
                            Image(systemName: "globe")
                                .font(.title)
                                .foregroundColor(AppColors.accentBlue)
                        }
                    }
                    ScenarioControlsView(
                        onScenario: { viewModel.send(.simulate($0)) },
                        onReset: { viewModel.send(.resetSimulation) }
                    )
                    WeekStripView(
                        days: state.weekDays,
                        selectedDay: state.selectedDay,
                        onSelect: { viewModel.send(.selectDay($0)) }
                    )
                    actionButtons
                    DayTimelineView(
                        zones: state.zones,
                        items: state.timelineItems,
                        onMove: { sessionID, points in
                            viewModel.send(
                                .moveSession(
                                sessionID: sessionID,
                                verticalPoints: points,
                                hourHeight: DayTimelineView.hourHeight
                                )
                            )
                        },
                        onTap: { viewModel.send(.presentEditTask($0)) }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .scrollDismissesKeyboard(.interactively)

            if state.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .padding(22)
                    .background(
                        AppMaterials.loadingOverlay,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let nudge = state.activeNudge {
                GamifiedNudgeView(model: nudge) { action in
                    viewModel.send(.performNudgeAction(action.id))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.94)))
            }
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.52, dampingFraction: 0.78),
            value: state.activeNudge != nil
        )
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: state.timelineItems)
        .sheet(item: sheetBinding) { sheet in
            sheetContent(sheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert(L10n.Schedule.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) { viewModel.send(.dismissError) }
        } message: {
            Text(state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
        .task { viewModel.send(.appeared) }
        .sensoryFeedback(.impact(weight: .medium), trigger: state.timelineItems.count)
    }

    private var actionButtons: some View {
        HStack(spacing: 13) {
            AppButton(
                title: L10n.Schedule.addTask,
                icon: "plus.circle.fill",
                color: AppColors.accentGreen,
                onTap: { viewModel.send(.presentCreateTask) }
            )
            .accessibilityIdentifier("add-task-button")
            AppButton(
                title: L10n.Schedule.addGoal,
                icon: "trophy.fill",
                color: AppColors.accentPurple,
                onTap: { viewModel.send(.presentCreateGoal) }
            )
            .accessibilityIdentifier("add-goal-button")
        }
    }

    @ViewBuilder
    private func sheetContent(_ sheet: ScheduleTimelineSheet) -> some View {
        switch sheet {
        case .createTask:
            TaskEditorSheet(
                task: nil,
                zones: viewModel.state.zoneOptions,
                selectedDay: viewModel.state.selectedDay,
                onSave: { title, duration, zoneID, isSplittable, blocking in
                    viewModel.send(
                        .createTask(
                            ScheduleTaskSubmission(
                                title: title,
                                durationMinutes: duration,
                                zoneID: zoneID,
                                isSplittable: isSplittable,
                                blocking: blocking
                            )
                        )
                    )
                }
            )
        case .createGoal:
            GoalCreatorSheet(
                zones: viewModel.state.zoneOptions,
                startDay: viewModel.state.selectedDay,
                onCreate: { name, zoneID, duration in
                    viewModel.send(
                        .createGoal(
                            ScheduleGoalSubmission(
                                name: name,
                                zoneID: zoneID,
                                taskDurationMinutes: duration
                            )
                        )
                    )
                }
            )
        case let .editTask(id):
            if let task = viewModel.state.taskEditorsByID[id] {
                TaskEditorSheet(
                    task: task,
                    zones: viewModel.state.zoneOptions,
                    selectedDay: viewModel.state.selectedDay,
                    onSave: { title, duration, zoneID, isSplittable, blocking in
                        viewModel.send(
                            .updateTask(
                                taskID: task.id,
                                submission: ScheduleTaskSubmission(
                                    title: title,
                                    durationMinutes: duration,
                                    zoneID: zoneID,
                                    isSplittable: isSplittable,
                                    blocking: blocking
                                )
                            )
                        )
                    },
                    onDelete: { viewModel.send(.deleteTask(task.id)) }
                )
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { if !$0 { viewModel.send(.dismissError) } }
        )
    }

    private var sheetBinding: Binding<ScheduleTimelineSheet?> {
        Binding(
            get: { viewModel.state.presentedSheet },
            set: { if $0 == nil { viewModel.send(.dismissSheet) } }
        )
    }
}
