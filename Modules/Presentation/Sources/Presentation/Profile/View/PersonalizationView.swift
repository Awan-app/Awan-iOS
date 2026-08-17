import Common
import Domain
import Foundation
import SwiftUI

struct PersonalizationView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: SettingsViewModel
    @State private var isSessionTimeSheetPresented = false
    @State private var isTimeZoneSheetPresented = false
    @State private var isSleepScheduleSheetPresented = false

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    AppBackButton(
                        accessibilityLabel: L10n.CalendarScreen.back,
                        onTap: { coordinator.mainCoordinator.pop() }
                    )

                    Text(L10n.Profile.personalization)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .layoutPriority(1)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(AppColors.screenBackground)

                content
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isSessionTimeSheetPresented) {
            SessionTimeSheet(
                initialDuration: viewModel.sessionTime > 0 ? viewModel.sessionTime : 60,
                onSave: { duration in
                    Task {
                        if await viewModel.updateSessionTime(duration) {
                            isSessionTimeSheetPresented = false
                        }
                    }
                },
                onDismiss: {
                    isSessionTimeSheetPresented = false
                }
            )
            .overlay { mutationOverlay(for: .sessionDuration) }
            .alert(
                L10n.Profile.updateFailureTitle,
                isPresented: Bindable(viewModel).showError
            ) {
                Button(L10n.Common.gotIt, role: .cancel) {}
            } message: {
                Text(L10n.Common.pleaseTryAgain)
            }
        }
        .sheet(isPresented: $isTimeZoneSheetPresented) {
            TimeZoneSheet(
                currentTimeZone: viewModel.timeZone,
                onSave: { identifier in
                    Task {
                        if await viewModel.updateTimeZone(identifier) {
                            isTimeZoneSheetPresented = false
                        }
                    }
                },
                onDismiss: {
                    isTimeZoneSheetPresented = false
                }
            )
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
            .overlay { mutationOverlay(for: .timeZone) }
            .alert(
                L10n.Profile.updateFailureTitle,
                isPresented: Bindable(viewModel).showError
            ) {
                Button(L10n.Common.gotIt, role: .cancel) {}
            } message: {
                Text(L10n.Common.pleaseTryAgain)
            }
        }
        .sheet(isPresented: $isSleepScheduleSheetPresented) {
            SleepScheduleSheet(
                initialWakeUpTime: viewModel.wakeupTime,
                initialSleepTime: viewModel.sleepTime,
                onSave: { wakeupTime, sleepTime in
                    Task {
                        if await viewModel.updateSleepSchedule(
                            wakeupTime: wakeupTime,
                            sleepTime: sleepTime
                        ) {
                            isSleepScheduleSheetPresented = false
                        }
                    }
                },
                onDismiss: {
                    isSleepScheduleSheetPresented = false
                }
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
            .overlay { mutationOverlay(for: .sleepSchedule) }
            .alert(
                L10n.Profile.updateFailureTitle,
                isPresented: Bindable(viewModel).showError
            ) {
                Button(L10n.Common.gotIt, role: .cancel) {}
            } message: {
                Text(L10n.Common.pleaseTryAgain)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView()
                .tint(AppColors.accentBlue)
                .accessibilityLabel(L10n.Profile.loading)

        case .failure:
            loadFailure

        case .content:
            ScrollView {
                PreferencesCard(preferences: preferenceItems)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }

    private var preferenceItems: [PreferenceItem] {
        [
            PreferenceItem(
                icon: "clock",
                title: L10n.Profile.sessionTime,
                value: formattedSessionTime,
                onTap: { isSessionTimeSheetPresented = true }
            ),
            PreferenceItem(
                icon: "globe",
                title: L10n.Profile.timeZone,
                value: viewModel.timeZone,
                onTap: { isTimeZoneSheetPresented = true }
            ),
            PreferenceItem(
                icon: "moon",
                title: L10n.Profile.sleepSchedule,
                value: formattedSleepSchedule,
                onTap: { isSleepScheduleSheetPresented = true }
            ),
            PreferenceItem(
                icon: "square.grid.2x2",
                title: L10n.Categories.title,
                value: "",
                onTap: { coordinator.mainCoordinator.push(MainRoute.categories) }
            )
        ]
    }

    private var formattedSessionTime: String {
        guard viewModel.sessionTime > 0 else { return "" }
        return L10n.Home.minutesShort(viewModel.sessionTime)
    }

    private var formattedSleepSchedule: String {
        guard let wakeupTime = viewModel.wakeupTime,
              let sleepTime = viewModel.sleepTime else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = languageManager.locale

        var wakeupComponents = DateComponents()
        wakeupComponents.hour = wakeupTime.hour
        wakeupComponents.minute = wakeupTime.minute

        var sleepComponents = DateComponents()
        sleepComponents.hour = sleepTime.hour
        sleepComponents.minute = sleepTime.minute

        guard let wakeupDate = Calendar.current.date(from: wakeupComponents),
              let sleepDate = Calendar.current.date(from: sleepComponents) else {
            return ""
        }

        return "\(formatter.string(from: sleepDate)) – \(formatter.string(from: wakeupDate))"
    }

    private var loadFailure: some View {
        AppDepthSurface(
            surfaceColor: AppColors.warningSurface,
            borderColor: AppColors.warning.opacity(0.34),
            depthColor: AppColors.warning.opacity(0.42)
        ) {
            VStack(spacing: 16) {
                Text(L10n.Profile.loadFailure)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                AppButton(
                    title: L10n.Home.retry,
                    color: AppColors.accentBlue,
                    onTap: {
                        Task { await viewModel.load() }
                    }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
    }

    @ViewBuilder
    private func mutationOverlay(for mutation: SettingsMutation) -> some View {
        if viewModel.activeMutation == mutation {
            ZStack {
                AppColors.shadow.opacity(0.16)
                    .ignoresSafeArea()

                ProgressView()
                    .tint(AppColors.accentBlue)
                    .padding(18)
                    .background(
                        AppColors.surface,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonalizationView(
            viewModel: SettingsViewModel(
                getUserProfileUseCase: MockGetUserProfileUseCase(),
                updateSessionDurationUseCase: MockUpdateSessionDurationUseCase(),
                updateTimezoneUseCase: MockUpdateTimezoneUseCase(),
                updateSleepScheduleUseCase: MockUpdateSleepScheduleUseCase()
            )
        )
    }
    .environment(AppCoordinator())
    .environment(LanguageManager())
    .environment(AppearanceManager())
}
