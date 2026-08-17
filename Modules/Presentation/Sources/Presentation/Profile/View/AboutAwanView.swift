import Common
import SwiftUI

struct AboutAwanView: View {
    @Environment(AppCoordinator.self) private var coordinator
    private let version: String
    private let build: String

    init(bundle: Bundle = .main) {
        version = bundle.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "—"
        build = bundle.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "—"
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

                    Text(L10n.Profile.aboutAwan)
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
                    AppDepthSurface(
                        surfaceColor: AppColors.infoSurface,
                        borderColor: AppColors.accentBlue.opacity(0.28),
                        depthColor: AppColors.accentBlueDepth.opacity(0.34)
                    ) {
                        VStack(spacing: 20) {
                            AwanMascotView()
                                .frame(width: 132, height: 132)

                            Text(L10n.Onboarding.welcomeTitle)
                                .font(AppFonts.titleBlack)
                                .foregroundStyle(AppColors.brandDarkBlue)
                                .multilineTextAlignment(.center)

                            Text(L10n.Onboarding.welcomeSubtitle)
                                .font(AppFonts.bodySemibold)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            Rectangle()
                                .fill(AppColors.divider)
                                .frame(height: 1)

                            HStack(spacing: 20) {
                                versionItem(
                                    title: L10n.Profile.version,
                                    value: version
                                )
                                versionItem(
                                    title: L10n.Profile.build,
                                    value: build
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(24)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func versionItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)

            Text(value)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview("About Awan Light") {
    NavigationStack {
        AboutAwanView()
    }
}

#Preview("About Awan Dark") {
    NavigationStack {
        AboutAwanView()
    }
    .preferredColorScheme(.dark)
}
