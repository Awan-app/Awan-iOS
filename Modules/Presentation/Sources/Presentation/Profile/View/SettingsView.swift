import Common
import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var isLanguageSheetPresented = false
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = false
    @State private var isNotificationsPickerPresented = false

    @State private var showNotificationPromptAlert = false

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

                    Text(L10n.Profile.settings)
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

                ScrollView {
                    VStack(spacing: 18) {
                        LanguageThemeCard(
                            language: languageManager.currentLanguage == .arabic
                                ? L10n.Profile.languageArabic
                                : L10n.Profile.languageEnglish,
                            onLanguageTap: {
                                isLanguageSheetPresented = true
                            }
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderLabel(title: L10n.Profile.general, accentColor: AppColors.warning)

                            DepthCardContainer {
                                VStack(spacing: 0) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.badge.fill")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(AppColors.destructive)
                                            .frame(width: 26, alignment: .center)
                                        
                                        Text(L10n.Profile.manageNotifications)
                                            .font(AppFonts.subheadlineBold)
                                            .foregroundStyle(AppColors.textPrimary)
                                        
                                        Spacer(minLength: 8)
                                        
                                        Button { isNotificationsPickerPresented = true } label: {
                                            HStack(spacing: 6) {
                                                Circle()
                                                    .fill(isNotificationsEnabled ? AppColors.accentGreen : AppColors.destructive)
                                                    .frame(width: 8, height: 8)
                                                
                                                Text(isNotificationsEnabled ? L10n.Profile.enabled : L10n.Profile.disabled)
                                                    .font(AppFonts.subheadlineBold)
                                                    .foregroundStyle(AppColors.brandDarkBlue)
                                                
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundStyle(AppColors.textSecondary)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .popover(isPresented: $isNotificationsPickerPresented, arrowEdge: .bottom) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                notificationOption(
                                                    title: L10n.Profile.enabled,
                                                    isSelected: isNotificationsEnabled
                                                ) {
                                                    handleNotificationSelection(true)
                                                }
                                                Divider().overlay(AppColors.accentBlue.opacity(0.14))
                                                notificationOption(
                                                    title: L10n.Profile.disabled,
                                                    isSelected: !isNotificationsEnabled
                                                ) {
                                                    handleNotificationSelection(false)
                                                }
                                            }
                                            .padding(10)
                                            .frame(minWidth: 180)
                                            .background(AppColors.surface)
                                            .presentationCompactAdaptation(.popover)
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    
                                    Rectangle()
                                        .fill(AppColors.divider)
                                        .frame(height: 1)
                                        .padding(.leading, 38)
                                        .padding(.vertical, 6)

                                    Button(action: {
                                        coordinator.mainCoordinator.push(MainRoute.mcpIntegration)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "point.3.connected.trianglepath.dotted")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(AppColors.accentBlue)
                                                .frame(width: 26, alignment: .center)

                                            Text(L10n.Profile.mcpIntegration)
                                                .font(AppFonts.subheadlineBold)
                                                .foregroundStyle(AppColors.textPrimary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer(minLength: 8)

                                            Image(systemName: "chevron.forward")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                                        }
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)

                                    Rectangle()
                                        .fill(AppColors.divider)
                                        .frame(height: 1)
                                        .padding(.leading, 38)
                                        .padding(.vertical, 6)

                                    Button(action: {
                                        coordinator.mainCoordinator.push(MainRoute.aboutAwan)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "info.circle.fill")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(AppColors.accentGreen)
                                                .frame(width: 26, alignment: .center)

                                            Text(L10n.Profile.aboutAwan)
                                                .font(AppFonts.subheadlineBold)
                                                .foregroundStyle(AppColors.textPrimary)
                                                .multilineTextAlignment(.leading)

                                            Spacer(minLength: 8)

                                            Image(systemName: "chevron.forward")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                                        }
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .id(languageManager.currentLanguage)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isLanguageSheetPresented) {
            LanguageSelectionView()
        }
        .alert(
            L10n.Profile.notificationPromptTitle,
            isPresented: $showNotificationPromptAlert
        ) {
            Button(L10n.Profile.dontAllow, role: .cancel) {
                isNotificationsEnabled = false
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                NotificationCenter.default.post(name: Notification.Name("NotificationsToggled"), object: nil)
            }
            Button(L10n.Profile.allow) {
                isNotificationsEnabled = true
                Task {
                    _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                    NotificationCenter.default.post(name: Notification.Name("NotificationsToggled"), object: nil)
                }
            }
        } message: {
            Text(L10n.Profile.notificationPromptMessage)
        }
    }

    private func handleNotificationSelection(_ enabled: Bool) {
        isNotificationsPickerPresented = false
        if !enabled {
            isNotificationsEnabled = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            NotificationCenter.default.post(name: Notification.Name("NotificationsToggled"), object: nil)
        } else {
            showNotificationPromptAlert = true
        }
    }
}

@MainActor
@ViewBuilder
private func notificationOption(
    title: String,
    isSelected: Bool,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        HStack(spacing: 10) {
            Circle()
                .fill(isSelected ? AppColors.accentGreen : AppColors.runtimeFallback)
                .frame(width: 10, height: 10)
            Text(title)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.brandDarkBlue)
                .lineLimit(1)
            Spacer(minLength: 12)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.accentGreen)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
}

#Preview("Language Appearance Light") {
    NavigationStack {
        SettingsView()
    }
    .environment(AppCoordinator())
    .environment(LanguageManager())
    .environment(AppearanceManager())
}

#Preview("Language Appearance Dark") {
    NavigationStack {
        SettingsView()
    }
    .environment(AppCoordinator())
    .environment(LanguageManager())
    .environment(AppearanceManager())
    .preferredColorScheme(.dark)
}
