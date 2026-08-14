import Common
import SwiftUI

struct CalendarView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: CalendarViewModel
    private let onSelectDate: (Date) -> Void

    init(
        viewModel: CalendarViewModel,
        onSelectDate: @escaping (Date) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectDate = onSelectDate
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 18) {
                    header

                    CalendarMonthView(
                        month: viewModel.state.displayedMonth,
                        selectedDate: viewModel.state.selectedDate,
                        goals: viewModel.state.goals,
                        activityDays: viewModel.state.activityDays,
                        navigationDirection: viewModel.state.monthNavigationDirection,
                        onSelectDate: { date in
                            viewModel.send(.selectDate(date))
                            onSelectDate(date)
                            coordinator.mainCoordinator.pop()
                        },
                        onPreviousMonth: {
                            viewModel.send(.showPreviousMonth)
                        },
                        onNextMonth: {
                            viewModel.send(.showNextMonth)
                        }
                    )

                    goalsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .refreshable { viewModel.send(.refresh) }

            if viewModel.state.isLoading {
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
        .toolbar(.hidden, for: .tabBar)
        .task(id: languageManager.currentLanguage) {
            viewModel.send(
                .appeared(
                    calendar: languageManager.calendar,
                    locale: languageManager.locale
                )
            )
        }
        .alert(
            L10n.Home.errorTitle,
            isPresented: failureBinding
        ) {
            Button(L10n.Common.gotIt) {
                viewModel.send(.dismissError)
            }
        } message: {
            Text(viewModel.state.failureMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                coordinator.mainCoordinator.pop()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(AppFonts.subheadlineBlack)
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(AppDepthButtonStyle())
            .accessibilityLabel(L10n.CalendarScreen.back)

            Text(L10n.Home.calendar)
                .font(AppFonts.titleBlack)
                .foregroundStyle(AppColors.brandDarkBlue)

            Spacer()

            AwanMascotView()
                .frame(width: 58, height: 58)
        }
    }

    @ViewBuilder
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.CalendarScreen.activeGoals)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.brandDarkBlue)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.state.goals.isEmpty, !viewModel.state.isLoading {
                AppDepthSurface {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(AppFonts.nudgeSymbol)
                            .foregroundStyle(AppColors.accentBlue)
                        Text(L10n.CalendarScreen.emptyTitle)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(L10n.CalendarScreen.emptyMessage)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            } else {
                ForEach(viewModel.state.goals) { goal in
                    CalendarGoalCard(goal: goal)
                }
            }
        }
    }

    private var failureBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.failureMessage != nil },
            set: {
                if !$0 {
                    viewModel.send(.dismissError)
                }
            }
        )
    }

}
