//
//  MCPConnectionDetailsSection.swift
//  Presentation
//

import Common
import SwiftUI

struct MCPConnectionDetailsSection: View {
    let mcpText: String?
    let isLoading: Bool
    
    @State private var didCopy = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: "MCP Connection Details",
                accentColor: AppColors.accentBlue
            )
            
            AppDepthSurface(
                surfaceColor: AppColors.infoSurface,
                borderColor: AppColors.accentBlue.opacity(0.3),
                depthColor: AppColors.accentBlue.opacity(0.4)
            ) {
                HStack(alignment: .top, spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                    } else if let mcpText = mcpText {
                        Text(mcpText)
                            .font(Font.caption.monospaced())
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            copyToClipboard(text: mcpText)
                        } label: {
                            Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(didCopy ? AppColors.reward : AppColors.accentBlue)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Copy MCP Connection Details")
                    } else {
                        Text("Failed to load connection details.")
                            .font(Font.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
                .padding(16)
            }
        }
    }
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        didCopy = true
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                didCopy = false
            }
        }
    }
}

#Preview {
    VStack {
        MCPConnectionDetailsSection(
            mcpText: "MCP URL:\nhttps://awanproduction.up.railway.app/mcp\n\nClient ID:\nawan-mcp",
            isLoading: false
        )
        MCPConnectionDetailsSection(mcpText: nil, isLoading: true)
        MCPConnectionDetailsSection(mcpText: nil, isLoading: false)
    }
    .padding()
    .background(AppColors.screenBackground)
}
