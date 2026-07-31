//
//  ProposedTaskSessionsRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProposedTaskSessionsRow: View {
    let fixedSessions: [ProposedSession]
    let aiSessions: [ProposedSession]

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !fixedSessions.isEmpty {
                sessionGroup(
                    icon: "pin.fill",
                    label: L10n.Home.proposedTaskFixedSession,
                    color: AppColors.accentPurple,
                    sessions: fixedSessions,
                    chipBackground: AppColors.accentPurple.opacity(0.1)
                )
            }

            if !aiSessions.isEmpty {
                sessionGroup(
                    icon: "sparkles",
                    label: L10n.Home.proposedTaskAiSession,
                    color: AppColors.accentBlue,
                    sessions: aiSessions,
                    chipBackground: AppColors.accentBlue.opacity(0.12)
                )
            }
        }
    }

    @ViewBuilder
    private func sessionGroup(
        icon: String,
        label: String,
        color: Color,
        sessions: [ProposedSession],
        chipBackground: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(AppFonts.caption2Bold)
                Text(label)
                    .font(AppFonts.caption2Bold)
            }
            .foregroundStyle(color)

            FlowRow(spacing: 6) {
                ForEach(sessions) { session in
                    Text("\(Self.timeFormatter.string(from: session.start)) – \(Self.timeFormatter.string(from: session.end))")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(chipBackground, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

// MARK: - Simple Flow Row

private struct FlowRow<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        // Uses HStack with wrapping via fixedSize — simple approach
        HStack(spacing: spacing) {
            content
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
