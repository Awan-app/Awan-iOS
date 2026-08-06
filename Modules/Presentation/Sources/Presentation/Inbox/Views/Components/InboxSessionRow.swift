//
//  InboxSessionRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct InboxSessionRow: View {
    let session: InboxSessionItem

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.08))
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppColors.accentBlue.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.accentBlue)
            }

            Text(session.timeRangeText)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 2) {
                badgeView(for: session.displayStatus)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.screenBackground.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.outline.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func badgeView(for status: InboxSessionDisplayStatus) -> some View {
        switch status {
        case .activeNow:
            Text(L10n.Inbox.sessionsActiveNow)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.accentGreen.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.accentGreen.opacity(0.4), lineWidth: 1)
                )
        case .missed:
            Text(L10n.Inbox.sessionsMissed)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.destructive)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.destructive.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.destructive.opacity(0.4), lineWidth: 1)
                )
        case .scheduled:
            Text(L10n.Inbox.sessionsScheduled)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.accentBlue.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1)
                )
        case .completed:
            Text(L10n.Inbox.filterCompleted)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.accentGreen.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.accentGreen.opacity(0.4), lineWidth: 1)
                )
        case .cancelled:
            Text(L10n.Inbox.filterCancelled)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.destructive)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.destructive.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.destructive.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

#Preview("Session Row Active Now") {
    InboxSessionRow(
        session: .init(
            id: UUID(),
            timeRangeText: "Today, 10:00–11:00 AM",
            displayStatus: .activeNow,
            underlyingStatus: .planned
        )
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Session Row Missed") {
    InboxSessionRow(
        session: .init(
            id: UUID(),
            timeRangeText: "Yesterday, 3:00–4:00 PM",
            displayStatus: .missed,
            underlyingStatus: .planned
        )
    )
    .padding()
    .background(AppColors.screenBackground)
}
