import Common
import Domain
import SwiftUI

struct MCPConnectionView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: MCPConnectionViewModel

    init(viewModel: MCPConnectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(L10n.Profile.mcpSubtitle)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MCPConnectionContent(state: viewModel.state) {
                        Task { await viewModel.load() }
                    }
                }
                .id(languageManager.currentLanguage)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle(L10n.Profile.mcpIntegration)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task {
            if viewModel.state == .idle {
                await viewModel.load()
            }
        }
    }
}

private struct MCPConnectionContent: View {
    let state: MCPConnectionState
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColors.accentBlue)
                .frame(maxWidth: .infinity, minHeight: 180)
                .accessibilityLabel(L10n.Profile.loading)

        case let .content(details):
            MCPConnectionDetailsSection(details: details)

        case .failure:
            AppDepthSurface(
                surfaceColor: AppColors.warningSurface,
                borderColor: AppColors.warning.opacity(0.34),
                depthColor: AppColors.warning.opacity(0.42)
            ) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.cloud.fill")
                        .font(AppFonts.heroSymbol)
                        .foregroundStyle(AppColors.warning)

                    Text(L10n.Profile.failedLoadMcpConnection)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)

                    AppButton(
                        title: L10n.Home.retry,
                        color: AppColors.accentBlue,
                        onTap: onRetry
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview("MCP Integration Light") {
    NavigationStack {
        MCPConnectionView(
            viewModel: MCPConnectionViewModel(
                fetchConnectionDetailsUseCase: MockFetchMCPConnectionDetailsUseCase()
            )
        )
    }
    .environment(LanguageManager())
}

#Preview("MCP Integration Dark") {
    NavigationStack {
        MCPConnectionView(
            viewModel: MCPConnectionViewModel(
                fetchConnectionDetailsUseCase: MockFetchMCPConnectionDetailsUseCase()
            )
        )
    }
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
