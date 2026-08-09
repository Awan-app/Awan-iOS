import Common
import Domain
import SwiftUI

struct ProfileMainView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    content
                        .padding(.horizontal, 24)
                        .padding(.bottom, 90)
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationBarHidden(true)
        .alert(
            L10n.Profile.logout,
            isPresented: Bindable(viewModel).showLogoutConfirmation
        ) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.Profile.logout, role: .destructive) {
                Task { await viewModel.logout() }
            }
        } message: {
            Text(L10n.Profile.logoutConfirmationMessage)
        }
        .alert(
            L10n.Profile.updateFailureTitle,
            isPresented: Bindable(viewModel).showLogoutError
        ) {
            Button(L10n.Common.gotIt, role: .cancel) {}
        } message: {
            Text(L10n.Common.pleaseTryAgain)
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
                .frame(maxWidth: .infinity, minHeight: 360)
                .accessibilityLabel(L10n.Profile.loading)

        case .failure:
            loadFailure

        case .content:
            profileContent
                .id(languageManager.currentLanguage)
        }
    }

    private var profileContent: some View {
        VStack(spacing: 14) {
            ProfileHeroCard(
                avatarImage: Image("user-avatar"),
                name: viewModel.userName,
                email: viewModel.userEmail,
                points: viewModel.points,
                streak: viewModel.streak,
                maxStreak: viewModel.maxStreak,
                onEdit: {
                    coordinator.mainCoordinator.push(MainRoute.userInfo)
                }
            )

            ProfileNavigationButton(
                icon: "shippingbox.fill",
                title: L10n.Profile.inventory,
                subtitle: nil,
                color: AppColors.accentPurple,
                action: {
                    coordinator.mainCoordinator.push(MainRoute.inventory)
                }
            )

            DailyZonesCard(
                zones: viewModel.dailyZones,
                isReady: viewModel.areDailyZonesReady,
                onTap: {
                    coordinator.mainCoordinator.push(MainRoute.dailyZones)
                }
            )

            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderLabel(
                    title: L10n.Profile.more,
                    accentColor: AppColors.accentBlue
                )

                ProfileMenuCard(items: [
                    ProfileMenuItem(
                        icon: "wand.and.stars",
                        title: L10n.Profile.personalization,
                        color: AppColors.accentBlue,
                        action: {
                            coordinator.mainCoordinator.push(MainRoute.personalization)
                        }
                    ),
                    ProfileMenuItem(
                        icon: "slider.horizontal.3",
                        title: L10n.Profile.settings,
                        color: AppColors.warning,
                        action: {
                            coordinator.mainCoordinator.push(MainRoute.settings)
                        }
                    )
                ])
            }

            AppButton(
                title: L10n.Profile.logout,
                color: AppColors.destructive,
                onTap: {
                    viewModel.showLogoutConfirmation = true
                }
            )
            .padding(.top, 8)
            .disabled(viewModel.isLoggingOut)
        }
        .padding(.top, 6)
    }

    private var loadFailure: some View {
        AppDepthSurface(
            surfaceColor: AppColors.warningSurface,
            borderColor: AppColors.warning.opacity(0.34),
            depthColor: AppColors.warning.opacity(0.42)
        ) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.cloud.fill")
                    .font(AppFonts.heroSymbol)
                    .foregroundStyle(AppColors.warning)

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
        .padding(.top, 40)
    }
}

#Preview {
    ProfileMainView(
        viewModel: ProfileViewModel(
            getUserProfileUseCase: MockGetUserProfileUseCase(),
            fetchZonesUseCase: MockFetchZonesUseCase(),
            logoutUseCase: LogoutUseCase(repository: MockAuthRepository())
        )
    )
    .environment(AppCoordinator())
    .environment(LanguageManager())
}
