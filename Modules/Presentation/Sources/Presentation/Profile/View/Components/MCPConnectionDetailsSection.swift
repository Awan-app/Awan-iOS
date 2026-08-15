import Common
import Domain
import SwiftUI

struct MCPConnectionDetailsSection: View {
    let details: MCPConnectionDetails

    var body: some View {
        AppDepthSurface(
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlue.opacity(0.30)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.Profile.mcpConnectionDetails)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)

                MCPConnectionDetailRow(
                    title: L10n.Profile.mcpServerURL,
                    value: details.mcpUrl,
                    copyAccessibilityLabel: L10n.Profile.copyMcpServerURL
                )

                MCPConnectionDetailRow(
                    title: L10n.Profile.oauthClientID,
                    value: details.clientId,
                    copyAccessibilityLabel: L10n.Profile.copyOAuthClientID
                )
            }
        }
    }
}

#Preview("MCP Details Light") {
    MCPConnectionDetailsSection(
        details: MCPConnectionDetails(
            mcpUrl: "https://backend.example.com/api/v1/mcp",
            clientId: "awan-ios-client"
        )
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("MCP Details Dark") {
    MCPConnectionDetailsSection(
        details: MCPConnectionDetails(
            mcpUrl: "https://backend.example.com/api/v1/mcp",
            clientId: "awan-ios-client"
        )
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
