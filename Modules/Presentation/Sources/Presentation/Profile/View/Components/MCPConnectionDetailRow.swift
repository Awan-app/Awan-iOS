import Common
import SwiftUI
import UIKit

struct MCPConnectionDetailRow: View {
    let title: String
    let value: String
    let copyAccessibilityLabel: String

    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: 10) {
                Text(value)
                    .font(AppFonts.captionMonospacedMedium)
                    .foregroundStyle(AppColors.textPrimary)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    copyValue()
                } label: {
                    Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(didCopy ? AppColors.accentGreen : AppColors.accentBlue)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        shape: .roundedRectangle(cornerRadius: 8),
                        surfaceColor: AppColors.infoSurface,
                        borderColor: AppColors.accentBlue.opacity(0.24),
                        depthColor: AppColors.accentBlue.opacity(0.30),
                        depthOffset: 3,
                        pressedOffset: 2
                    )
                )
                .accessibilityLabel(copyAccessibilityLabel)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                AppColors.screenBackground,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.18), lineWidth: 1)
            }
        }
    }

    private func copyValue() {
        UIPasteboard.general.string = value
        didCopy = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            didCopy = false
        }
    }
}

#Preview("MCP Detail Light") {
    MCPConnectionDetailRow(
        title: "MCP Server URL",
        value: "https://backend.example.com/api/v1/mcp",
        copyAccessibilityLabel: "Copy MCP Server URL"
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("MCP Detail Dark") {
    MCPConnectionDetailRow(
        title: "OAuth Client ID",
        value: "awan-ios-client",
        copyAccessibilityLabel: "Copy OAuth Client ID"
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}
