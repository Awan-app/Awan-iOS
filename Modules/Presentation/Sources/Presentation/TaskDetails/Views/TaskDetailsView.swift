import Common
import Domain
import SwiftUI

struct TaskDetailsView: View {
    @State private var viewModel: TaskDetailsViewModel
    let onDismiss: () -> Void

    init(viewModel: TaskDetailsViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        let state = viewModel.state

        AppSheet(sizing: .large, backgroundColor: AppColors.sheetBackground) {
            ZStack(alignment: .top) {
                AppColors.sheetBackground.ignoresSafeArea()

                AppCloudsHorizon(height: 220)
                    .frame(maxWidth: .infinity)

                if state.isLoading && state.snapshot == nil {
                    ProgressView()
                        .controlSize(.large)
                } else if let snapshot = state.snapshot {
                    VStack(spacing: 0) {
                        TaskDetailsHeaderView(
                            task: snapshot.task,
                            remainingRewardPoints: snapshot.remainingRewardPoints,
                            areAllSessionRewardsClaimed: snapshot.areAllSessionRewardsClaimed,
                            totalDurationMinutes: snapshot.totalDurationMinutes,
                            onClose: { viewModel.send(.attemptDismiss) },
                            onDelete: { viewModel.send(.requestDeleteTask) }
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 18)
                        .padding(.bottom, 14)

                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 18) {
                                TaskDetailsInformationSection(
                                    title: Binding(
                                        get: { viewModel.state.title },
                                        set: { viewModel.send(.setTitle($0)) }
                                    ),
                                    description: Binding(
                                        get: { viewModel.state.description },
                                        set: { viewModel.send(.setDescription($0)) }
                                    )
                                )

                                TaskDetailsSessionsSection(
                                    sessions: snapshot.sessions,
                                    onAdd: { viewModel.send(.showAddSession) },
                                    onEdit: { viewModel.send(.editSession($0)) },
                                    onDelete: { viewModel.send(.requestDeleteSession($0)) }
                                )

                                TaskDetailsSettingsSection(
                                    mandatory: Binding(
                                        get: { viewModel.state.mandatory },
                                        set: { viewModel.send(.setMandatory($0)) }
                                    ),
                                    isSplittable: Binding(
                                        get: { viewModel.state.isSplittable },
                                        set: { viewModel.send(.setSplittable($0)) }
                                    ),
                                    categories: state.categories,
                                    zones: state.zones,
                                    selectedCategoryID: state.selectedCategoryID,
                                    categoryErrorMessage: state.categoryErrorMessage,
                                    onSelectCategory: {
                                        viewModel.send(.setCategory($0))
                                    },
                                    onRetryCategories: {
                                        viewModel.send(.retryCategories)
                                    }
                                )

                                TaskDetailsGoalSection(
                                    goal: snapshot.goal,
                                    onAdd: { viewModel.send(.showGoals) },
                                    onRemove: { viewModel.send(.requestRemoveGoal) }
                                )

                                TaskDetailsDependenciesSection(
                                    dependencies: snapshot.dependencies,
                                    onAdd: { viewModel.send(.showDependencies) },
                                    onRemove: {
                                        viewModel.send(.requestRemoveDependency($0))
                                    }
                                )

                                .padding(.bottom, 36)
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 4)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            TaskDetailsSaveChangesBar(
                                canSave: state.canSave,
                                isSaving: state.isSaving,
                                onSave: { viewModel.send(.save) }
                            )
                        }
                    }
                }

                if state.isMutating {
                    ProgressView()
                        .controlSize(.large)
                        .padding(22)
                        .background(
                            AppMaterials.loadingOverlay,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                }
            }
        }
        .background {
            SheetDismissAttemptObserver(
                isDismissalDisabled: state.isDirty || state.isBusy,
                onAttempt: { viewModel.send(.attemptDismiss) }
            )
        }
        .interactiveDismissDisabled(state.isDirty || state.isBusy)
        .task { viewModel.send(.appeared) }
        .onChange(of: state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { onDismiss() }
        }
        .sheet(item: presentedSheetBinding) { sheet in
            switch sheet {
            case .goals:
                TaskDetailsGoalPickerSheet(
                    goals: viewModel.state.goals,
                    onSelect: { viewModel.send(.selectGoal($0)) },
                    onDismiss: { viewModel.send(.dismissPresentedSheet) }
                )
            case .dependencies:
                TaskDetailsDependencyPickerSheet(
                    tasks: viewModel.state.dependencyCandidates,
                    sourceName: viewModel.state.snapshot?.goal?.name
                        ?? L10n.Inbox.tabInbox,
                    onSelect: { viewModel.send(.selectDependency($0)) },
                    onDismiss: { viewModel.send(.dismissPresentedSheet) }
                )
            case .newSession:
                TaskSessionScheduleEditorSheet(
                    defaultDurationMinutes: min(
                        max(viewModel.state.snapshot?.task.duration.minutes ?? 30, 15),
                        60
                    ),
                    onSave: { start, end in
                        viewModel.send(.createSession(start: start, end: end))
                    },
                    onDismiss: { viewModel.send(.dismissPresentedSheet) }
                )
            case .session(let session):
                TaskSessionScheduleEditorSheet(
                    session: session,
                    onSave: { start, end in
                        viewModel.send(
                            .saveSession(
                                sessionID: session.id,
                                start: start,
                                end: end
                            )
                        )
                    },
                    onDismiss: { viewModel.send(.dismissPresentedSheet) }
                )
            }
        }
        .alert(
            L10n.TaskDetails.discardTitle,
            isPresented: confirmationBinding(.discardChanges)
        ) {
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
            Button(L10n.TaskDetails.discard, role: .destructive) {
                viewModel.send(.discardAndDismiss)
            }
        } message: {
            Text(L10n.TaskDetails.discardMessage)
        }
        .alert(
            L10n.Inbox.deleteTaskConfirmTitle,
            isPresented: confirmationBinding(.deleteTask)
        ) {
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
            Button(L10n.Inbox.deleteTask, role: .destructive) {
                viewModel.send(.confirmAction)
            }
        } message: {
            Text(L10n.Inbox.deleteTaskConfirmMessage)
        }
        .alert(
            L10n.TaskDetails.deleteSessionTitle,
            isPresented: deleteSessionConfirmationBinding
        ) {
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
            Button(L10n.Home.deleteSession, role: .destructive) {
                viewModel.send(.confirmAction)
            }
        } message: {
            Text(L10n.TaskDetails.deleteSessionMessage)
        }
        .alert(
            relationConfirmationTitle,
            isPresented: relationConfirmationBinding
        ) {
            Button(relationConfirmationButtonTitle, role: .destructive) {
                viewModel.send(.confirmAction)
            }
            Button(L10n.Common.cancel, role: .cancel) {
                viewModel.send(.cancelConfirmation)
            }
        } message: {
            Text(relationConfirmationMessage)
        }
        .alert(
            L10n.Home.errorTitle,
            isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { if !$0 { viewModel.send(.dismissError) } }
            )
        ) {
            Button(L10n.Common.gotIt) { viewModel.send(.dismissError) }
        } message: {
            Text(state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private var presentedSheetBinding: Binding<TaskDetailsPresentedSheet?> {
        Binding(
            get: { viewModel.state.presentedSheet },
            set: { if $0 == nil { viewModel.send(.dismissPresentedSheet) } }
        )
    }

    private func confirmationBinding(
        _ confirmation: TaskDetailsConfirmation
    ) -> Binding<Bool> {
        Binding(
            get: { viewModel.state.confirmation == confirmation },
            set: { if !$0 { viewModel.send(.cancelConfirmation) } }
        )
    }

    private var deleteSessionConfirmationBinding: Binding<Bool> {
        Binding(
            get: {
                if case .deleteSession = viewModel.state.confirmation { true }
                else { false }
            },
            set: { if !$0 { viewModel.send(.cancelConfirmation) } }
        )
    }

    private var relationConfirmationBinding: Binding<Bool> {
        Binding(
            get: {
                switch viewModel.state.confirmation {
                case .removeGoal, .removeDependency: true
                default: false
                }
            },
            set: { if !$0 { viewModel.send(.cancelConfirmation) } }
        )
    }

    private var relationConfirmationTitle: String {
        if case .removeGoal = viewModel.state.confirmation {
            L10n.TaskDetails.removeGoalTitle
        } else {
            L10n.TaskDetails.removeDependencyTitle
        }
    }

    private var relationConfirmationButtonTitle: String {
        if case .removeGoal = viewModel.state.confirmation {
            L10n.TaskDetails.removeGoal
        } else {
            L10n.TaskDetails.removeDependency
        }
    }

    private var relationConfirmationMessage: String {
        if case .removeGoal = viewModel.state.confirmation {
            L10n.TaskDetails.removeGoalMessage
        } else {
            L10n.TaskDetails.removeDependencyMessage
        }
    }
}
